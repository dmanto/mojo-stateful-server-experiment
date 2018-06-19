# mojo-stateful-server-experiment
Just an experiment of a stateful server

- you need to have a postgresql database named "test", and your user should have permissions to create / drop tables on it
- requires Mojolicious and Mojo::Pg installed (see cpanfile, or run `cpanm --installdeps .`)
- Run the server whith hypnotoad:

```
$> hypnotoad stateful.pl
```

  That will start the server. There is a post route (`/tokens/create`) that will create a token whith an "advanced" field that
  will evolve up to 100 in 10 seconds aprox. The route renders inmediatelly with a json that contains an url field that will
  be used to get the status of the advanced field.
  
- This oneliner will allow you to create a token and then interrogate the advance status every second, a total of 15 times:

```
$> perl -Mojo -E 'my $b=":8080";my $u=p("$b/tokens/create")->json->{url};n {say g($u)->body;sleep 1} 15'
```
  
- The `40clients.sh` script will run the same oneliner, but for 40 simultaneous clients.

```
$> ./40clients.sh
```

- The point of the experiment is that the state machines (recurring loops) keep woriking despite the fact that the controller
that created them already rendered its content.
  
- I have to verify yet if it leaks any memory.
  
