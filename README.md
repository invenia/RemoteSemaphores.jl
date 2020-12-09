# RemoteSemaphores

[![CI](https://github.com/Invenia/RemoteSemaphores.jl/workflows/CI/badge.svg)](https://github.com/Invenia/RemoteSemaphores.jl/actions?query=workflow%3ACI)
[![CodeCov](https://codecov.io/gh/invenia/RemoteSemaphores.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/RemoteSemaphores.jl)

## Documentation

```julia
RemoteSemaphore(n::Int, pid=myid())
```

A `RemoteSemaphore` is a [counting semaphore](https://www.quora.com/What-is-a-counting-semaphore) that lives on a particular process in order to control access to a resource from multiple processes.
It is implemented using the unexported `Base.Semaphore` stored inside a `Future` which is only accessed on the process it was initialized on.
Like `Base.Semaphore`, it implements `acquire` and `release`, and is not thread-safe.
