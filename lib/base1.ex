defmodule Base1 do
  @moduledoc """
  This module encodes and decodes Base1.

  ## Overview

  According to the author of Base1:

    ```
    Base1 encodes arbitrary binary data as a string of repeated "A" characters.
    With analogy to the unary numeral system, the binary data is encoded in the length of the string.
    ```

  Base1 is designed to be relatively inefficient, but accurate.

  There are three main ways to encode and decode data as Base1 in this module:

    * Using `encode/1` and `decode/1` or `decode!/1` to produce a sequence of repeated "A" characters. This does not scale.
    * Using `encode_length/1` and `decode_length!/1` or `decode_length/1`. This scales better, though is still relatively inefficient. It is much more compact, however and supports larger inputs.
    * Using `encode_length_bin/1` and `decode_length_bin!/1` or ``decode_length_bin/1`. This scales better, but not as well as pure length encoding due to the string conversion. This exists mostly to provide a convenience for interfaces that need Base1 and expect Elixir binary input and output.

  ## Resources

  * [Base 1 Canonical Implementation](https://github.com/qntm/base1)
  """

  @typedoc """
  A Base1 encoded binary.
  """
  @type base1_binary() :: <<_::8>>

  @doc """
  Encodes a binary as a Base1 string.

  ## Examples

      iex> Base1.encode!(<<1>>)
      "AA"

      iex> Base1.encode!("b")
      "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

      iex> Base1.encode!(<<>>)
      <<>>

  """
  @spec encode!(binary()) :: base1_binary()
  def encode!(data) when is_binary(data) do
    do_encode(data)
  end

  def encode!(_data) do
    raise ArgumentError, "data must be a valid binary"
  end

  @doc """
  Encodes a binary as a Base1 string.

  ## Examples

      iex> Base1.encode(<<1>>)
      {:ok, "AA"}

      iex> Base1.encode("b")
      {:ok, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}

      iex> Base1.encode(<<>>)
      {:ok, <<>>}

  """
  @spec encode(binary()) :: {:ok, base1_binary()} | :error
  def encode(data) do
    {:ok, do_encode(data)}
    rescue
      ArgumentError -> :error
  end

  @doc """
  Encodes a binary as a Base1 length.

  ## Examples

      Base1.encode_length(<<0>>
      1

      Base1.encode_length(<<1>>)
      2

      Base1.encode_length("hi")
      26986

      Base1.encode_length(<<0x03, 0xC0>>)
      1217

  """
  @spec encode_length(binary()) :: non_neg_integer()
  def encode_length(data) when is_binary(data) do
    do_encode_length(data)
  end

  @doc """
  Encodes a binary as a Base1 length string.

  ## Examples

      Base1.encode_length_bin(<<0>>
      "1"

      Base1.encode_length_bin(<<1>>)
      "2"

      Base1.encode_length_bin("hi")
      "26986"

      Base1.encode_length_bin(<<0x03, 0xC0>>)
      "1217"

  """
  @spec encode_length_bin(binary()) :: binary()
  def encode_length_bin(data) do
    encode_length(data) |> Integer.to_string()
  end

  @doc """
  Decodes a Base1 string as binary.

  Raises an ArgumentError if the input string is not a Base1 binary.

  ## Examples

      iex> Base1.decode!("A")
      <<0>>

      iex> Base1.decode!("AA")
      <<1>>

      iex> Base1.decode!("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
      "b"

  """
  @spec decode!(base1_binary()) :: binary()
  def decode!(string) when is_binary(string) do
    do_decode(string)
  end

  @doc """
  Decodes a Base1 string as binary.

  Returns `:error` if the input string is not a Base1 binary.

  ## Examples

      iex> Base1.decode("A")
      {:ok, <<0>>}

      iex> Base1.decode("AA")
      {:ok, <<1>>}

      iex> Base1.decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
      {:ok, "b"}

      iex> Base1.decode("AAAAAAHHH BLACK BEAST OF")
      :error

  """
  @spec decode(base1_binary()) :: {:ok, binary()} | :error
  def decode(string) when is_binary(string) do
    {:ok, decode!(string)}
  rescue
    ArgumentError -> :error
  end

  @doc """
  Decodes a Base1 string length.

  Raises an ArgumentError if the length is not a non-negative integer.

  ## Examples

      iex> Base1.decode_length!(1)
      <<0>>

      iex> Base1.decode_length!(2)
      <<1>>

      iex> Base1.decode_length!(381115146191751804757868696628784997)
      "Hello Cleveland"

      iex> Base1.decode_length!(9479543125109159158650175321189934146175361938985120077868441490465756706997907027887945065)
      "It is probably better to encode length"

  """
  @spec decode_length!(non_neg_integer()) :: binary()
  def decode_length!(number) when is_integer(number) and number >= 0 do
    decode_blocks(number)
  end

  def decode_length!(_number) do
    raise ArgumentError, "Base1 lengths are non-negative integers."
  end

  @doc """
  Decodes a Base1 string length.

  Returns `:error` if the length is not a non-negative integer.

  ## Examples

      iex> Base1.decode_length(1)
      {:ok, <<0>>}

      iex> Base1.decode_length(2)
      {:ok, <<1>>}

      iex> Base1.decode_length(381115146191751804757868696628784997)
      {:ok, "Hello Cleveland"}

      iex> Base1.decode_length(9479543125109159158650175321189934146175361938985120077868441490465756706997907027887945065)
      {:ok, "It is probably better to encode length"}

      iex> Base1.decode_length(-256)
      :error

  """
  @spec decode_length(non_neg_integer()) :: {:ok, binary()} | :error
  def decode_length(number) do
    {:ok, decode_length!(number)}
    rescue
      ArgumentError -> :error
  end

  @doc """
  Decodes a Base1 string length encoded as a string.

  Raises an ArgumentError if the length is not a non-negative integer string.

  ## Examples

      iex> Base1.decode_length_bin!("1")
      <<0>>

      iex> Base1.decode_length_bin!("2")
      <<1>>

      iex> Base1.decode_length_bin!("381115146191751804757868696628784997")
      "Hello Cleveland"

      iex> Base1.decode_length_bin!("9479543125109159158650175321189934146175361938985120077868441490465756706997907027887945065")
      "It is probably better to encode length"

  """
  @spec decode_length_bin!(binary()) :: binary()
  def decode_length_bin!(data) do
    String.to_integer(data) |> decode_length!()
  end

  @doc """
  Decodes a Base1 string length encoded as a string.

  `:error` is returned if the length is not a non-negative integer string.

  ## Examples

      iex> Base1.decode_length_bin("1")
      {:ok, <<0>>}

      iex> Base1.decode_length_bin("2")
      {:ok, <<1>>}

      iex> Base1.decode_length_bin("381115146191751804757868696628784997")
      {:ok, "Hello Cleveland"}

      iex> Base1.decode_length_bin("9479543125109159158650175321189934146175361938985120077868441490465756706997907027887945065")
      {:ok, "It is probably better to encode length"}

      iex> Base1.decode_length_bin("cheddar cheese please")
      :error

  """
  @spec decode_length_bin(binary()) :: binary()
  def decode_length_bin(data) do
    {:ok, decode_length_bin!(data)}
    rescue
      ArgumentError -> :error
  end

  #===============================================================================
  # Privacy
  #===============================================================================

  # this meager power function doesn't convert from integer or overflow as easily
  # as the built-in :math.pow(), so we use it here
  defp pow(n, k) do
    pow(n, k, 1)
  end

  defp pow(_n, 0, acc) do
    acc
  end

  defp pow(n, k, acc) do
    pow(n, k - 1, n * acc)
  end

  defp do_encode(<<>> = data) do
    data
  end

  defp do_encode(data) do
    data_length = do_encode_length(data)
    #TODO: resolve limited binary size issue
    # There is a hard limit on the maximum size of a binary
    # in 64-bit VMs it is 2,305,843,009,213,693,951 bytes
    # in 32-bit VMs it is 536,870,911 bytes
    # further, when trying to invoke binary copy, a large size can easily cause malloc issues depending on the config
    # this can bring down the entire VM due to the NIF call
    # Here we try to rescue things in advance
    # One option is to construct several binaries and return a series perhaps, but we will still probably risk exceeding memory limits

    # this is a sloppy patch for now, probably there is better system_info to use or perhaps it's better to check some info about the heap
    # it is probably best to never use base1, but here we are
    max_bin_size = case :erlang.system_info(:wordsize) do
      4 -> 536_870_911
      _ -> 2_305_843_009_213_693_951
    end

    if data_length >= max_bin_size  do
      raise ArgumentError, "Data is too large to binary encode as Base1 #{inspect data_length} bytes are required. Use encode_length/1 and decode_length/1 instead."
    end
    :binary.copy("A", data_length)
  end

  defp do_encode_length(<<>>) do
    0
  end

  defp do_encode_length(data) do
    blocks = byte_size(data) - 1
    do_encode_length(blocks, 0) + :binary.decode_unsigned(data)
  end

  defp do_encode_length(0, acc) do
    acc + 1
  end

  defp do_encode_length(remaining_blocks, acc) do
    val = pow(256, remaining_blocks)
    do_encode_length(remaining_blocks - 1, acc + val)
  end

  defp do_decode(<<>>) do
    <<>>
  end

  defp do_decode(string) do
    # verify we have only As to ensure we are running very slow, but accurate
    # using byte_size(data) would not ensure we have valid Base1 data and be faster, which we don't want
    bin_length = calculate_length(string, 0)
    decode_blocks(bin_length, 1, 0)
  end

  defp calculate_length(<<>>, acc) do
    acc
  end

  defp calculate_length(<<"A", rest::binary>>, acc) do
    calculate_length(rest, acc + 1)
  end

  defp calculate_length(_string, _acc) do
    raise ArgumentError, "Input string is not a valid Base1 string."
  end

  defp decode_blocks(0) do
    <<>>
  end

  defp decode_blocks(bin_length) do
    decode_blocks(bin_length, 1, 0)
  end

  defp decode_blocks(bin_length, block_size, acc) when bin_length >= block_size do
    decode_blocks(bin_length - block_size, block_size * 256, acc + 1)
  end

  defp decode_blocks(bin_length, _block_size, acc) do
    encode_buffer(bin_length, acc - 1, [])
  end

  defp encode_buffer(bin_length, byte_number, encoded_chars) when byte_number >= 0 do
    # likely we can do some tricks like using encoding unsigned to make this faster and skip some pre-steps,
    # but we want to adhere to the inherent sluggishness of this algorithm
    #TODO: something better for unicode - we follow the JS algorithm, so we need to check if it's acceptable to do this another way
    char = rem(bin_length, 256)
    quotient = (bin_length - char) |> div(256)
    encode_buffer(quotient, byte_number - 1, [char | encoded_chars])
  end

  defp encode_buffer(_bin_length, _byte_number, encoded_chars) do
    # we take an ugly approach from the JS so we work with unicode unsafe here.
    encoded_chars |> IO.iodata_to_binary()
  end

end
