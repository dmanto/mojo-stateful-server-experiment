# mojo-stateful-server-experiment
Just an experiment of a stateful server

- you need to have a postgresql database named "test", and your user should have permissions to create / drop tables on it
- requires Mojolicious and Mojo::Pg installed (see cpanfile, or run `cpanm --installdeps .`)
- Run the server whith hypnotoad:

```
$> hypnotoad stateful.pl
```

  That will start the serever. There is a post route (`/tokens/create`) that will create a token whith an "advanced" field that
  will evolve up to 100 in 10 seconds aprox. The route renders inmediatelly with a json that contains an url field that will
  be used to get the status of the advanced field.
  
  - The `40clients.sh` script will fire 40 simultaneous clients that will create a token, and then check the status 15 times, once
  per second.
  
  - The point of the experiment is that the state machines (recurring loops) keep woriking despite the fact that the controller
  that created them already rendered its content.
  
  - I have to verify yet if it leaks any memory.
  
