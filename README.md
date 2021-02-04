# XUtil

**`main` build status**: [![main build status](https://circleci.com/gh/X-Plane/elixir-xutil/tree/main.svg?style=svg)](https://circleci.com/gh/X-Plane/elixir-xutil/tree/main) **Latest commit build status**: [![Last commit build status](https://circleci.com/gh/X-Plane/elixir-xutil.svg?style=svg)](https://circleci.com/gh/X-Plane/elixir-xutil)

Various utility code shared by X-Plane's Elixir codebase.

Some of this is X-Plane-specific (like the DSF module, used for working with X-Plane's scenery files),
but a lot of it is domain-agnostic (e.g., the Enum and GenServer utilities). 

## Testing

[We use CircleCI](https://app.circleci.com/pipelines/github/X-Plane/elixir-xutil) to run the test suite on every commit.

You can run the same tests that CircleCI does like so:

1. Run the Credo linter: `$ mix credo --strict`
2. Confirm the code matches the official formatter: `$ mix format --check-formatted`
3. Confirm the tests pass: `$ mix test` (or if you like more verbose output, `$ mix test --trace`)
