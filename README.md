# Base1

Base1 is an Elixir library for encoding and decoding Base1 binaries.

`Base1` is an Elixir port of [Base1](https://github.com/qntm/base1). Please read the "How it Works" section to learn more.

```
Binary encoding inspired by unary numbers.
```

The main reason `Base1` exists is to support Base1 encoding and decoding as part of [Multibase](https://github.com/multiformats/multibase) and other implementations that require dispatch to Base codecs.

## Why

You probably should not use Base1 encoding unless you are building a multi-codec for Base encoding/decoding of some sort. It is grossly inefficient, slow, and according to some enlightened few, an abomination.

If these concerns still do not deter you, then you may find the following use-cases applicable for `Base1`:

* Testing the durability of your laptop fans
* Using CPU and memory that Chrome (or via Electron), poorly written software, or other programs fail to consume
* Re-purposing your computer as a pancake griddle.
* Implementing some sort of perverse unary computer emulator or behavior
* "A" is an invaluable letter to you
* You want to use a library that does not claim that it is fast. This is not fast unless your perception is wildly different than from a reasonable human.

## Usage

If you want semi-unreasonable performance, it is best to work with lengths instead of binaries. You can do so as either integers or integers encoded as strings. The latter if for the case where your interface demands a binary (string) type returned.

Let's first be unreasonable and encode a binary to see why lengths are better:

```elixir
# let's encode something very simple
Base1.encode!(<<4>>)
"AAAAA"

Base1.encode!("1")
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

# pay our respects
 Base1.encode!("F")
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

# If we want to give our CPU a workout
Base1.encode!("hello")
# output: lots of As, may take awhile

# we need to be careful encoding things that will produce giant binaries, or otherwise encode length instead
Base1.encode("huge binary to encode, but not really")
:error

Base1.encode!("huge binary to encode, but not really")
# raises ** (ArgumentError) Data is too large to binary encode as Base1 52448966988976840295297313244602659742710332201806431846112755526506725455904981438524794 bytes are required. Use encode_length/1 and decode_length/1 instead.
# perhaps we should listen....
```

Likewise, we can decode our binaries and show that encoding and decoding are transparent.

```elixir
Base1.decode!("AAAAA")
<<4>>

Base1.decode!("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
"1"

#indeed
Base1.decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
"F"

# Fully transparent
Base1.encode!(<<1, 2, 3>>) |> Base1.decode!()
<<1, 2, 3>>

# We can handle errors too if we want pattern matching
Base1.encode!(<<1, 2, 3>>) |> Base1.decode()
{:ok, <<1, 2, 3>>}

# bad input data
Base1.decode("This is not base1, for it it does not scream to us")
:error
```

Now let's take a slightly more sane approach using lengths, all things considered.

```elixir
# encodes much faster than binary
Base1.encode_length("hello")                                                           
452690013552

Base1.decode_length!(452690013552)  
"hello"

# we can use our error handling flavor as before too
Base1.decode_length(452690013552)  
{:ok, "hello"}


# also fully transparent and works better for larger input binaries than `encode/1`
 Base1.encode_length("Lettuceless Burritos Are Best Burritos") |> Base1.decode_length!()
"Lettuceless Burritos Are Best Burritos"
```

Fortunately, we can also take another approach if we really want our encoded data as binary, not numbers.

```elixir
Base1.encode_length_bin("hello")
"452690013552"

# bigger strings now work too, just like with `encode_length/1`
Base1.encode_length_bin("Big strings are better when they are string cheese")
"680015850116389379759636622830644424760636765950574532108918486844800528727880164921633865142384902132161451816034661478"

# decoding works as everything else before it did
Base1.decode_length_bin!("452690013552")
"hello"

# and as before, we maintain transparency
Base1.encode_length_bin("not as fun as encoding lots of As") |> Base1.decode_length_bin!() 
"not as fun as encoding lots of As"
```

## Limitations

* `Base1.encode/1` - this function is not suitable for most data more than a few bytes long. The issue is that the Base1 design requires a very large block of memory allocated, while the limits outlined in the [Erlang Effieincy Guide](http://erlang.org/doc/efficiency_guide/advanced.html) conflict with this requirement. Attempting to `malloc` large amounts of bytes can crash the VM. As such, the current design prevents you from doing this. See "Size of a binary" for more discussion.
    * If you feel inclined to come up with a design that fixes it, I welcome the input. As it stands right now, it's hardly worth addressing for my usage.
* `Memory usage` - if your runtime memory allotment is very small, `encode/1` can still cause massive issues for you. Beware.
* Common sense - use length encoding if for some reason you *really* need to encode something large

## Installation

`Base1` is available via [Hex](https://hex.pm/packages/base1). The package can be installed by adding `base1` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:base1, "~> 0.1.0"}
  ]
end
```

API Documentation can be found at [https://hexdocs.pm/base1/base1.html](https://hexdocs.pm/base1.html).
