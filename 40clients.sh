#!/bin/bash
for r in {1..40}
do 
  perl -Mojo -E 'my $u=p(":8080/tokens/create")->json->{url};n {say g($u)->body;sleep 1} 15' &
done
