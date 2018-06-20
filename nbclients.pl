#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::UserAgent;
use Time::HiRes 'time';

my $tini = time;
my $ua   = Mojo::UserAgent->new;
$ua->max_connections(0);    # no keep alive

my $n = $ARGV[0] // 1;
for my $i (1 .. $n) {
  $ua->post_p('http://localhost:8080/tokens/create')->then(sub {
    my $tx = shift;
    say sprintf "%2.3f %s", time - $tini, $tx->result->body;
    my $url  = $tx->result->json->{url};
    my $cant = 15;
    my $rid;
    $rid = $ua->ioloop->recurring(
      1 => sub {
        $ua->get_p($url)->then(sub {
          my $tx = shift;
          say sprintf "%2.3f %s", time - $tini, $tx->result->body;
        })->catch(sub {
          my $err = shift;
          warn "Get error: $err";
        })->wait;
        $ua->ioloop->remove($rid) unless --$cant;
      }
    );
  })->catch(sub {
    my $err = shift;
    warn "Post error: $err";
  })->wait;
}
$ua->ioloop->start;
