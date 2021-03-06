package App::dategrep::Iterator::Fh;
use strict;
use warnings;
use Moo;
use FileHandle;
extends 'App::dategrep::Iterator';

has fh => ( is => 'ro', required => 1 );
has end_passed => ( is => 'rw', default => sub { 0 } );

sub get_entry_unbuffered {
    my $self = shift;

    return if $self->end_passed || $self->fh->eof;

  LINE:
    while ( my $entry = $self->getline() ) {

        if ( $self->multiline ) {
            while (!$self->fh->eof
                && !$self->end_passed
                && !$self->next_line_has_date )
            {
                $entry .= $self->getline();
            }
        }
        my ( $epoch, $error ) = $self->to_epoch( $entry );
        if ( !$epoch ) {
            next LINE if $self->skip_unparsable;
            die "Unparsable line: $entry\n";
        }
        if ( $epoch >= $self->end ) {
            $self->end_passed(1);
            return;
        }

        next LINE if $epoch < $self->start;

        return $entry;
    }
    return;

}

1;
