using RemoteSemaphores
using RemoteSemaphores: _current_count
using Compat.Test

using Compat.Dates
using Compat.Distributed

struct TimeoutException
    duration
end

function Base.showerror(io::IO, te::TimeoutException)
    print(io, "TimeoutException: Operation did not finish in ", te.duration)

    if !isa(te.duration, Period)
        print(io, " seconds")
    end
end

function asynctimedwait(fn, secs; kill=false)
    t = @async fn()
    timedwait(() -> istaskdone(t), secs)

    if istaskdone(t)
        fetch(t)
        return true
    else
        if kill
            Base.throwto(t, TimeoutException(secs))
        end

        return false
    end
end

@testset "RemoteSemaphores.jl" begin

@testset "Single Process" begin
    @test_throws ArgumentError RemoteSemaphore(0)

    rsem = RemoteSemaphore(2)
    @test _current_count(rsem) == 0

    try
        info("Expect \"ERROR (unhandled task failure)\" on Julia 0.6 only")
        asynctimedwait(1.0; kill=true) do
            release(rsem)
        end
        @test "Expected error but no error thrown" == nothing
    catch err
        @test err isa RemoteException
        @test err.captured.ex isa AssertionError

        if !isa(err, RemoteException) || !isa(err.captured.ex, AssertionError)
            rethrow(err)
        end
    end

    @test asynctimedwait(1.0; kill=true) do
        acquire(rsem)
    end
    @test _current_count(rsem) == 1

    @test asynctimedwait(1.0; kill=true) do
        acquire(rsem)
    end
    @test _current_count(rsem) == 2

    acquired = false
    @test asynctimedwait(1.0) do
        acquire(rsem)
        acquired = true
    end == false
    @test !acquired
    @test _current_count(rsem) == 2

    @test asynctimedwait(1.0; kill=true) do
        release(rsem)
    end
    @test acquired
    @test _current_count(rsem) == 2

    @test asynctimedwait(10.0; kill=true) do
        @sync for i = 1:100
            @async (isodd(i) ? acquire(rsem) : release(rsem))
        end
    end

    @test _current_count(rsem) == 2
end

@testset "Multiple Processes" begin
    @testset "Simple remote" begin
        worker_pid = addprocs(1)[1]
        @everywhere using RemoteSemaphores

        rsem = RemoteSemaphore(2, worker_pid)
        @test _current_count(rsem) == 0

        try
            info("Expect \"ERROR (unhandled task failure)\" on Julia 0.6 only")
            asynctimedwait(1.0; kill=true) do
                release(rsem)
            end
            @test "Expected error but no error thrown" == nothing
        catch err
            @test err isa RemoteException
            @test err.captured.ex isa AssertionError

            if !isa(err, RemoteException) || !isa(err.captured.ex, AssertionError)
                rethrow(err)
            end
        end

        @test asynctimedwait(1.0; kill=true) do
            acquire(rsem)
        end
        @test _current_count(rsem) == 1

        @test asynctimedwait(1.0; kill=true) do
            acquire(rsem)
        end
        @test _current_count(rsem) == 2

        acquired = false
        @test asynctimedwait(1.0) do
            acquire(rsem)
            acquired = true
        end == false
        @test !acquired
        @test _current_count(rsem) == 2

        @test asynctimedwait(1.0; kill=true) do
            release(rsem)
        end
        @test acquired
        @test _current_count(rsem) == 2

        @test asynctimedwait(10.0; kill=true) do
            @sync for i = 1:100
                @async (isodd(i) ? acquire(rsem) : release(rsem))
            end
        end

        @test _current_count(rsem) == 2
    end
end

end
