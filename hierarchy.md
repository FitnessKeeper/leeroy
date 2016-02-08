## General principles

* Objects interact with the world outside the program (_e.g._ I/O)
* Objects contain state
* Modules provide traits/behaviors/information common to multiple objects (_e.g._ logging)
* The Leeroy::App namespace defines the CLI (commands, runtime configuration)
* The Leeroy::Data namespace defines the persistence layer
* The Leeroy::Task namespace defines the application's capabilities
* The Leeroy::Helpers namespace contains only helper modules, no class definitions

## Hierarchy

classes are marked with `*`

```
Leeroy

Leeroy::App
Leeroy::App::Command
Leeroy::App::Command::Config
Leeroy::App::Command::Env
Leeroy::App::Command::State
Leeroy::App::Command::Task
Leeroy::App::Command::Version

Leeroy::Helpers
Leeroy::Helpers::AWS
Leeroy::Helpers::Env
Leeroy::Helpers::Polling
Leeroy::Helpers::State

Leeroy::Task
Leeroy::Task::Base *
Leeroy::Task::RunInstance *
Leeroy::Task::ImageInstance *
Leeroy::Task::TerminateInstance *

Leeroy::Version
```
