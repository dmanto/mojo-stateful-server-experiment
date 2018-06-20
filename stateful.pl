#!/usr/bin/env perl
use Mojolicious::Lite;
use Mojo::Pg;

helper pg => sub { state $pg = Mojo::Pg->new('postgresql:///test') };
app->pg->migrations->from_data->migrate;
app->log->path('stateful.log');
get(
  'tokens/:tkn' => sub {
    my $c   = shift;
    my $tkn = $c->stash('tkn');
    $c->pg->db->select_p(tokens => undef, {id => $tkn})->then(sub {
      if (my $res = shift->hashes->first) {
        my $adv = $res->{advance};
        $c->render(
          json => {
            advance => $adv,
            token   => $tkn,
            pid     => $$,     # any process can read the status of any token
          }
        );
      }
      else {
        app->log->error("Token $tkn not found");
        $c->render(text => "Token $tkn not found", status => 404);
      }
    })->catch(sub { app->log->error(shift); });
  }
)->name('get_token');

# creates a token with an internal advance from 1 to 33
# important point is that it renders inmediatelly
post '/tokens/create' => sub {
  my $c  = shift;
  my $db = $c->pg->db;
  my $tkn
    = $db->insert(tokens => {advance => 1}, {returning => 'id'})->hash->{id};
  my $rec_id;
  $rec_id
    = Mojo::IOLoop->recurring(  # this recurring loop would be the state machine
    0.3 => sub {
      my $nadv
        = $db->update(    # adds 3 units to advance, using an atomic sql update
        tokens => {advance => \"advance + 3"},
        {id => $tkn}, {returning => 'advance'}
      )->hash->{advance};
      Mojo::IOLoop->remove($rec_id)
        if $nadv >= 100;    # removing the recurring id stops the state machine
    }
    );
  $c->render(
    json => {
      advance => 0,
      token   => $tkn,
      url     => $c->url_for('get_token', tkn => $tkn)->to_abs,
      pid =>
        $$, # this process creates the token and keeps the state machine working
    },
    status => 201
  );
};

app->start;
__DATA__
@@ migrations
-- 1 up
create table if not exists tokens (id serial primary key, advance integer);
-- 1 down
drop table if exists tokens;
