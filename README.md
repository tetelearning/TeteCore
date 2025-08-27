TeteCore
========
[![Build Status](https://travis-ci.org/tetelearning/TeteCore.svg?branch=master)](https://travis-ci.org/tetelearning/TeteCore)

The core services and applications that drive the TeteLearning platform.

## Getting Started

You can get the application running on kind by creating a local cluster and using [Tilt](https://tilt.dev/) to deploy the services.

```
kind create cluster --name tete-local
tilt up
```