defmodule Base1Test do
  use ExUnit.Case, async: true
  doctest Base1

  test "encode/1 encodes an empty string" do
    assert Base1.encode!(<<>>) == <<>>
  end

  test "encode/1 encodes data as Base1 binary" do
    assert Base1.encode!(<<0>>) == "A"
    assert Base1.encode!(<<1>>) == "AA"
    assert Base1.encode!(<<2>>) == "AAA"
    assert Base1.encode!(<<255>>) == "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    assert Base1.encode!(<<1, 0>>) == "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  end

  test "encode_length/1 encodes data as a Base1 length" do
    assert Base1.encode_length(<<0>>) == 1
    assert Base1.encode_length(<<1>>) == 2
    assert Base1.encode_length(<<0x03, 0xc0>>) == 1217
    assert Base1.encode_length("Goodbye world") == 5739225900612881999752737287525
  end

  test "decode!/1 decodes Base1 to binary" do
    assert Base1.decode!("A") == <<0>>
    assert Base1.decode!("AA") == <<1>>
    assert Base1.decode!("AAA") == <<2>>
    assert Base1.decode!("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA") == <<255>>
    assert Base1.decode!("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")    == <<1, 0>>
  end

  test "decode/1 decodes Base1 to binary" do
    assert Base1.decode("A") == {:ok, <<0>>}
    assert Base1.decode("AA") == {:ok, <<1>>}
    assert Base1.decode("AAA") == {:ok, <<2>>}
    assert Base1.decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA") == {:ok, <<255>>}
    assert Base1.decode("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")    == {:ok, <<1, 0>>}
  end

  test "decode!/1 encodes an empty string" do
    assert Base1.decode!(<<>>) == <<>>
  end

  test "decode/1 decodes an empty string" do
    assert Base1.decode(<<>>) == {:ok, <<>>}
  end

  test "decode_length!/1 encodes an empty string" do
    assert Base1.decode_length!(0) == <<>>
  end

  test "decode_length/1 decodes an empty string" do
    assert Base1.decode_length(0) == {:ok, <<>>}
  end

  test "decode!/1 raises errors" do
    assert_raise ArgumentError, fn -> Base1.decode!("ABA") == :error end
    assert_raise ArgumentError, fn -> Base1.decode! Base1.decode!("Not base 1, never will be") == :error end
  end

  test "decode/1 handles errors" do
    assert Base1.decode("ABA") == :error
    assert Base1.decode("Not base 1, never will be") == :error
  end

  test "decode_length!/1 decodes Base1 length data" do
    assert Base1.decode_length!(1) == <<0>>
    assert Base1.decode_length!(2) == <<1>>
    #<<0x03, 0xc0>>
    assert Base1.decode_length!(1217) == <<3, 192>>
    assert Base1.decode_length!(5739225900612881999752737287525) == "Goodbye world"
  end

  test "decode_length/1 decodes Base1 length data" do
    assert Base1.decode_length(1) == {:ok, <<0>>}
    assert Base1.decode_length(2) == {:ok, <<1>>}
    # <<0x03, 0xc0>>
    assert Base1.decode_length(1217) == {:ok, <<3, 192>>}
    assert Base1.decode_length(5739225900612881999752737287525) == {:ok, "Goodbye world"}
  end

  test "Base1 transparently encodes and decodes data" do
    assert Base1.encode!("hi") |> Base1.decode!() == "hi"
    assert Base1.encode!(<<0, 1>>) |> Base1.decode!() == <<0, 1>>
    assert Base1.encode!(<<0, 0>>) |> Base1.decode!() == <<0, 0>>
    assert Base1.encode!(<<1, 0>>) |> Base1.decode!() == <<1, 0>>
  end

  test "decode_length!/1 raises errors" do
    assert_raise ArgumentError, fn -> Base1.decode_length!(-2000) == :error end
    assert_raise ArgumentError, fn -> Base1.decode_length!("wrong argument type") == :error end
  end

  test "decode_length/1 handles errors" do
    assert Base1.decode_length(-2000) == :error
    assert Base1.decode_length("wrong argument type") == :error
  end

  test "Base1 handles unicode, sort of, maybe" do
    assert Base1.encode!("ほ") |> Base1.decode!() == "ほ"
    #assert Base1.encode_length("ほほ") |> Base1.decode_length!() == "ほほ"
    #assert Base1.encode_length("ほほほ")

    # This crashes BEAM because our method with :binary.copy + malloc -> dragon is angered by trying to allocate insanity levels of memory
    #assert Base1.encode!("ほほほ") |> Base1.decode() == "ほほほ"
  end

end
