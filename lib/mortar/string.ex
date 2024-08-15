defmodule Mortar.String do
  @type split_by_newlines_option :: {:keep_newline, boolean()}

  # Borrowed from kuddle (v2)
  defguard is_utf8_bom_char(c) when c == 0xFEFF
  defguard is_utf8_digit_char(c) when c >= ?0 and c <= ?9
  defguard is_utf8_scalar_char(c) when (c >= 0x0000 and c <= 0xD7FF) or (c >= 0xE000 and c <= 0x10FFFF)
  defguard is_utf8_direction_control_char(c) when
    (c >= 0x200E and c <= 0x200F) or
    (c >= 0x2066 and c <= 0x2069) or
    (c >= 0x202A and c <= 0x202E)

  defguard is_utf8_space_like_char(c) when c in [
    0x09,
    0x0B,
    # Whitespace
    0x20,
    # No-Break Space
    0xA0,
    # Ogham Space Mark
    0x1680,
    # En Quad
    0x2000,
    # Em Quad
    0x2001,
    # En Space
    0x2002,
    # Em Space
    0x2003,
    # Three-Per-Em Space
    0x2004,
    # Four-Per-Em Space
    0x2005,
    # Six-Per-Em Space
    0x2006,
    # Figure Space
    0x2007,
    # Punctuation Space
    0x2008,
    # Thin Space
    0x2009,
    # Hair Space
    0x200A,
    # Narrow No-Break Space
    0x202F,
    # Medium Mathematical Space
    0x205F,
    # Ideographic Space
    0x3000,
  ]

  defguard is_utf8_newline_like_char(c) when c in [
    # New Line
    0x0A,
    # NP form feed, new pag
    0x0C,
    # Carriage Return
    0x0D,
    # Next-Line
    0x85,
    # Line Separator
    0x2028,
    # Paragraph Separator
    0x2029,
  ]

  defguard is_utf8_twochar_newline(c1, c2) when c1 == 0x0D and c2 == 0x0A

  def utf8_char_byte_size(c) when c < 0x80 do
    1
  end

  def utf8_char_byte_size(c) when c < 0x800 do
    2
  end

  def utf8_char_byte_size(c) when c < 0x10000 do
    3
  end

  def utf8_char_byte_size(c) when c >= 0x10000 do
    4
  end

  def split_upto_newline(blob) do
    do_split_upto_newline(blob, blob, 0)
  end

  defp do_split_upto_newline(
    blob,
    <<>>,
    _count
  ) do
    [blob]
  end

  defp do_split_upto_newline(
    blob,
    <<c1::utf8, c2::utf8, _rest::binary>>,
    count
  ) when is_utf8_twochar_newline(c1, c2) do
    <<seg::binary-size(count), rest::binary>> = blob
    [seg, rest]
  end

  defp do_split_upto_newline(
    blob,
    <<c::utf8, _rest::binary>>,
    count
  ) when is_utf8_newline_like_char(c) do
    <<seg::binary-size(count), rest::binary>> = blob
    [seg, rest]
  end

  defp do_split_upto_newline(
    blob,
    <<c::utf8, rest::binary>>,
    count
  ) do
    do_split_upto_newline(blob, rest, count + utf8_char_byte_size(c))
  end

  @spec split_by_newlines(binary(), [split_by_newlines_option()]) :: [binary()]
  def split_by_newlines(blob, options \\ []) do
    do_split_by_newlines(blob, blob, 0, [], options)
  end

  defp do_split_by_newlines(
    blob,
    <<>>,
    _count,
    acc,
    _options
  ) do
    Enum.reverse([blob | acc])
  end

  defp do_split_by_newlines(
    blob,
    <<c1::utf8, c2::utf8, _rest::binary>>,
    count,
    acc,
    options
  ) when is_utf8_twochar_newline(c1, c2) do
    # count + utf8_char_byte_size(c1) + utf8_char_byte_size(c2)
    if options[:keep_newline] do
      count = count + utf8_char_byte_size(c1) + utf8_char_byte_size(c2)
      <<seg::binary-size(count), rest::binary>> = blob
      do_split_by_newlines(rest, rest, 0, [seg | acc], options)
    else
      nl_size = utf8_char_byte_size(c1) + utf8_char_byte_size(c2)
      <<seg::binary-size(count), _nl::binary-size(nl_size), rest::binary>> = blob
      do_split_by_newlines(rest, rest, 0, [seg | acc], options)
    end
  end

  defp do_split_by_newlines(
    blob,
    <<c::utf8, _rest::binary>>,
    count,
    acc,
    options
  ) when is_utf8_newline_like_char(c) do
    if options[:keep_newline] do
      count = count + utf8_char_byte_size(c)
      <<seg::binary-size(count), rest::binary>> = blob
      do_split_by_newlines(rest, rest, 0, [seg | acc], options)
    else
      nl_size = utf8_char_byte_size(c)
      <<seg::binary-size(count), _nl::binary-size(nl_size), rest::binary>> = blob
      do_split_by_newlines(rest, rest, 0, [seg | acc], options)
    end
  end

  defp do_split_by_newlines(
    blob,
    <<c::utf8, rest::binary>>,
    count,
    acc,
    options
  ) do
    do_split_by_newlines(blob, rest, count + utf8_char_byte_size(c), acc, options)
  end

  @doc """
  Converts a list to a binary, this also handles tokenizer specific escape tuples.
  """
  @spec list_to_utf8_binary(list()) :: binary()
  def list_to_utf8_binary(list) when is_list(list) do
    list
    |> Enum.map(fn
      {:esc, c} when is_integer(c) -> <<c::utf8>>
      {:esc, c} when is_binary(c) -> c
      {:esc, c} when is_list(c) -> list_to_utf8_binary(c)
      c when is_integer(c) -> <<c::utf8>>
      c when is_binary(c) -> c
      c when is_list(c) -> list_to_utf8_binary(c)
    end)
    |> IO.iodata_to_binary()
  end

  @doc """
  Splits off as many space characters as possible
  """
  @spec split_spaces(binary(), list()) :: {spaces::binary(), rest::binary()}
  def split_spaces(rest, acc \\ [])

  def split_spaces(<<>> = rest, acc) do
    {list_to_utf8_binary(Enum.reverse(acc)), rest}
  end

  def split_spaces(<<c::utf8, rest::binary>>, acc) when is_utf8_space_like_char(c) do
    split_spaces(rest, [c | acc])
  end

  def split_spaces(rest, acc) do
    {list_to_utf8_binary(Enum.reverse(acc)), rest}
  end

  def split_spaces_and_newlines(rest, acc \\ [])

  def split_spaces_and_newlines(<<c::utf8, rest::binary>>, acc) when is_utf8_space_like_char(c) do
    split_spaces_and_newlines(rest, [c | acc])
  end

  def split_spaces_and_newlines(<<c1::utf8, c2::utf8, rest::binary>>, acc) when is_utf8_twochar_newline(c1, c2) do
    split_spaces_and_newlines(rest, [c2, c1 | acc])
  end

  def split_spaces_and_newlines(<<c::utf8, rest::binary>>, acc) when is_utf8_newline_like_char(c) do
    split_spaces_and_newlines(rest, [c | acc])
  end

  def split_spaces_and_newlines(rest, acc) do
    {list_to_utf8_binary(Enum.reverse(acc)), rest}
  end

  def truncate_spaces(bin, state \\ :start, acc \\ [])

  def truncate_spaces(<<>>, _, acc) do
    IO.iodata_to_binary(Enum.reverse(acc))
  end

  def truncate_spaces(
    <<c::utf8, rest::binary>>,
    :start,
    acc
  ) when is_utf8_space_like_char(c) or is_utf8_newline_like_char(c) do
    truncate_spaces(rest, :start, acc)
  end

  def truncate_spaces(
    <<c1::utf8, c2::utf8, rest::binary>>,
    :start,
    acc
  ) when is_utf8_twochar_newline(c1, c2) do
    truncate_spaces(rest, :start, acc)
  end

  def truncate_spaces(<<rest::binary>>, :start, acc) do
    truncate_spaces(rest, :body, acc)
  end

  def truncate_spaces(
    <<c::utf8, _rest::binary>> = rest,
    :body,
    acc
  ) when is_utf8_space_like_char(c) or is_utf8_newline_like_char(c) do
    case split_spaces_and_newlines(rest) do
      {_, "" = rest} ->
        truncate_spaces(rest, :body, acc)

      {_, rest} ->
        truncate_spaces(rest, :body, [" " | acc])
    end
  end

  def truncate_spaces(
    <<c1::utf8, c2::utf8, _rest::binary>> = rest,
    :body,
    acc
  ) when is_utf8_twochar_newline(c1, c2) do
    case split_spaces_and_newlines(rest) do
      {_, "" = rest} ->
        truncate_spaces(rest, :body, acc)

      {_, rest} ->
        truncate_spaces(rest, :body, [" " | acc])
    end
  end

  def truncate_spaces(<<c::utf8, rest::binary>>, :body, acc) do
    truncate_spaces(rest, :body, [<<c::utf8>> | acc])
  end

  def string_to_atom(value) when is_atom(value) do
    value
  end

  def string_to_atom(value) when is_binary(value) do
    String.to_existing_atom(value)
  end

  @spec atom_to_gql_enum(nil | atom() | String.t()) :: String.t()
  def atom_to_gql_enum(nil) do
    nil
  end

  def atom_to_gql_enum(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> atom_to_gql_enum()
  end

  def atom_to_gql_enum(str) when is_binary(str) do
    str
    |> String.upcase()
  end

  @doc """
  Returns nil if the value is nil, or the string is empty, otherwise returns the input value
  """
  @spec string_presence(any()) :: nil | any()
  def string_presence(nil), do: nil

  def string_presence(""), do: nil

  def string_presence(value) when is_binary(value) do
    if value =~ ~r/\A\s+\z/ do
      # it was completely blank
      nil
    else
      value
    end
  end

  def string_presence(value), do: value

  @spec is_string_present?(any()) :: boolean()
  def is_string_present?(value) do
    case string_presence(value) do
      nil ->
        false

      _ ->
        true
    end
  end

  def is_string_blank?(value) do
    not is_string_present?(value)
  end

  @doc """
  Scans the given list and returns the first element that evaluates &is_present?/1 to true

  Args:
  * `list` - the list to scan

  Returns:
  * `element` - the element that was present, or nil if nothing was found
  """
  @spec first_present_string(list()) :: any()
  def first_present_string(list) when is_list(list) do
    Enum.find(list, &is_string_present?/1)
  end

  def strip_non_printable(bin, acc \\ [])

  def strip_non_printable(<<>>, acc) do
    acc
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  def strip_non_printable(<<c::utf8, rest::binary>>, acc) do
    if String.printable?(<<c::utf8>>) do
      strip_non_printable(rest, [<<c::utf8>> | acc])
    else
      strip_non_printable(rest, acc)
    end
  end

  def strip_non_printable(<<_c, rest::binary>>, acc) do
    strip_non_printable(rest, acc)
  end

  @spec is_capitalized?(String.t()) :: boolean()
  def is_capitalized?(<<>>) do
    false
  end

  def is_capitalized?(<<c::utf8, _::binary>>) when c >= 0x41 and c <= 0x5A do
    true
  end

  def is_capitalized?(_) do
    false
  end

  def identify_casing(str, acc \\ :none)

  def identify_casing(<<>>, casing) do
    casing
  end

  def identify_casing(
    <<c::utf8, rest::binary>>,
    casing
  ) when c >= ?A and c <= ?Z and casing in [:none, :upcase], do: identify_casing(rest, :upcase)

  def identify_casing(
    <<c::utf8, rest::binary>>,
    casing
  ) when c >= ?a and c <= ?z and casing in [:none, :downcase], do: identify_casing(rest, :downcase)

  def identify_casing(
    <<_c::utf8, rest::binary>>,
    _
  ), do: identify_casing(rest, :mixed)

  @spec stream_binary_lines(binary()) :: Enum.t()
  def stream_binary_lines(bin) when is_binary(bin) do
    Stream.resource(
      fn ->
        # test if we can split on \r\n first
        case :binary.split(bin, "\r\n") do
          [_] ->
            # no, assume it's only newlines
            {bin, "\n"}

          [_, _] ->
            # it appears to work, assume the rest of the file is encoded in \r\n
            {bin, "\r\n"}
        end
      end,
      fn
        {<<>> = bin, pattern} ->
          {:halt, {bin, pattern}}

        {bin, pattern} ->
          case :binary.split(bin, pattern) do
            [blob, rest] ->
              {[blob], {rest, pattern}}

            [blob] ->
              {[blob], {<<>>, pattern}}
          end
      end,
      fn {<<>>, _pattern} ->
        :ok
      end
    )
  end

  @spec stream_binary_chunks(binary(), non_neg_integer()) :: Enum.t()
  def stream_binary_chunks(bin, chunk_size) do
    Stream.resource(
      fn ->
        bin
      end,
      fn
        <<>> ->
          {:halt, <<>>}

        bin ->
          case bin do
            <<chunk::binary-size(chunk_size), rest::binary>> ->
              {[chunk], rest}

            chunk when is_binary(chunk) ->
              {[chunk], <<>>}
          end
      end,
      fn _ ->
        :ok
      end
    )
  end

  @doc """
  Are all characters in the given string numbers?
  """
  @spec is_all_numeric?(String.t()) :: boolean
  def is_all_numeric?(""), do: true
  def is_all_numeric?(<<c, rest::binary>>) when c in ?0..?9, do: is_all_numeric?(rest)
  def is_all_numeric?(_), do: false

  @doc """
  Are all characters in the given string letters?
  """
  @spec is_all_alpha?(String.t()) :: boolean
  def is_all_alpha?(""), do: true
  def is_all_alpha?(<<c, rest::binary>>) when c in ?A..?Z or c in ?a..?z, do: is_all_alpha?(rest)
  def is_all_alpha?(_), do: false

  @doc """
  Are all characters in the given string numbers or letters?
  """
  @spec is_all_alpha_numeric?(String.t()) :: boolean
  def is_all_alpha_numeric?(""), do: true
  def is_all_alpha_numeric?(<<c, rest::binary>>) when c in ?0..?9, do: is_all_alpha_numeric?(rest)

  def is_all_alpha_numeric?(<<c, rest::binary>>) when c in ?A..?Z or c in ?a..?z,
    do: is_all_alpha_numeric?(rest)

  def is_all_alpha_numeric?(_), do: false

  @doc """
  Strips any non-alpha or non-digit characters from the string.

  If you need only digits, use `normalize_numeric/1` instead
  If you need only letters, use `normalize_alpha/1` instead
  """
  @spec normalize_alpha_numeric(String.t()) :: String.t()
  def normalize_alpha_numeric(number, acc \\ [])

  def normalize_alpha_numeric(<<>>, acc) do
    acc
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  def normalize_alpha_numeric(<<digit, rest::binary>>, acc) when digit in ?0..?9 do
    normalize_alpha_numeric(rest, [digit | acc])
  end

  def normalize_alpha_numeric(<<alpha, rest::binary>>, acc)
      when alpha in ?A..?Z or alpha in ?a..?z do
    normalize_alpha_numeric(rest, [alpha | acc])
  end

  def normalize_alpha_numeric(<<_, rest::binary>>, acc) do
    normalize_alpha_numeric(rest, acc)
  end

  @doc """
  Strips any non-letter character from the string
  """
  @spec normalize_alpha(String.t()) :: String.t()
  def normalize_alpha(number, acc \\ [])

  def normalize_alpha(<<>>, acc) do
    acc
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  def normalize_alpha(<<alpha, rest::binary>>, acc) when alpha in ?A..?Z or alpha in ?a..?z do
    normalize_alpha(rest, [alpha | acc])
  end

  def normalize_alpha(<<_, rest::binary>>, acc) do
    normalize_alpha(rest, acc)
  end

  @doc """
  Strips any non-digit character from the string
  """
  @spec normalize_numeric(String.t()) :: String.t()
  def normalize_numeric(number, acc \\ [])

  def normalize_numeric(<<>>, acc) do
    acc
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  def normalize_numeric(<<digit, rest::binary>>, acc) when digit in ?0..?9 do
    normalize_numeric(rest, [digit | acc])
  end

  def normalize_numeric(<<_, rest::binary>>, acc) do
    normalize_numeric(rest, acc)
  end

  @spec translate_mnemonic_string(String.t()) :: String.t()
  def translate_mnemonic_string(nanp) when is_binary(nanp) do
    do_translate_mnemonic_string(nanp, [])
  end

  @spec do_translate_mnemonic_string(String.t(), list) :: String.t()
  defp do_translate_mnemonic_string("", acc) do
    acc
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  mnemonic_map = %{
    "A" => "2",
    "B" => "2",
    "C" => "2",
    "D" => "3",
    "E" => "3",
    "F" => "3",
    "G" => "4",
    "H" => "4",
    "I" => "4",
    "J" => "5",
    "K" => "5",
    "L" => "5",
    "M" => "6",
    "N" => "6",
    "O" => "6",
    "P" => "7",
    "Q" => "7",
    "R" => "7",
    "S" => "7",
    "T" => "8",
    "U" => "8",
    "V" => "8",
    "W" => "9",
    "X" => "9",
    "Y" => "9",
    "Z" => "9",
    "a" => "2",
    "b" => "2",
    "c" => "2",
    "d" => "3",
    "e" => "3",
    "f" => "3",
    "g" => "4",
    "h" => "4",
    "i" => "4",
    "j" => "5",
    "k" => "5",
    "l" => "5",
    "m" => "6",
    "n" => "6",
    "o" => "6",
    "p" => "7",
    "q" => "7",
    "r" => "7",
    "s" => "7",
    "t" => "8",
    "u" => "8",
    "v" => "8",
    "w" => "9",
    "x" => "9",
    "y" => "9",
    "z" => "9"
  }

  for {letter, number} <- mnemonic_map do
    defp do_translate_mnemonic_string(<<unquote(letter), rest::binary>>, acc) do
      do_translate_mnemonic_string(rest, [unquote(number) | acc])
    end
  end

  defp do_translate_mnemonic_string(<<c::utf8, rest::binary>>, acc) do
    do_translate_mnemonic_string(rest, [c | acc])
  end
end
