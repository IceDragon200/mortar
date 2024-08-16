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

  @spec utf8_char_byte_size(char()) :: non_neg_integer()
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

  @doc """
  Splits a string up to the first newline
  """
  @spec split_upto_newline(String.t()) :: [String.t()]
  def split_upto_newline(blob) when is_binary(blob) do
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

  @doc """

  """
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
  Splits a string by its leading space as much as possible.

  The function will always return a 2-element tuple, the first element is the spaces and the second
  is the remainder of the string.
  """
  @spec split_leading_spaces(binary()) :: {spaces::binary(), rest::binary()}
  def split_leading_spaces(rest) do
    do_split_leading_spaces(rest, [])
  end

  defp do_split_leading_spaces(<<>> = rest, acc) do
    {list_to_utf8_binary(Enum.reverse(acc)), rest}
  end

  defp do_split_leading_spaces(<<c::utf8, rest::binary>>, acc) when is_utf8_space_like_char(c) do
    do_split_leading_spaces(rest, [c | acc])
  end

  defp do_split_leading_spaces(rest, acc) do
    {list_to_utf8_binary(Enum.reverse(acc)), rest}
  end

  @doc """
  Splits a string by its leading space and newlines as much as possible.

  The function will always return a 2-element tuple, the first element is the spaces or newlines
  and the second is the remainder of the string.

  This is the alternative to `split_leading_spaces/1` which only splits spaces.
  """
  @spec split_leading_spaces_and_newlines(binary()) ::
    {spaces_and_newlines::binary(), rest::binary()}
  def split_leading_spaces_and_newlines(rest) do
    do_split_leading_spaces_and_newlines(rest, [])
  end

  defp do_split_leading_spaces_and_newlines(
    <<c1::utf8, c2::utf8, rest::binary>>,
    acc
  ) when is_utf8_twochar_newline(c1, c2) do
    do_split_leading_spaces_and_newlines(rest, [c2, c1 | acc])
  end

  defp do_split_leading_spaces_and_newlines(
    <<c::utf8, rest::binary>>,
    acc
  ) when is_utf8_newline_like_char(c) do
    do_split_leading_spaces_and_newlines(rest, [c | acc])
  end

  defp do_split_leading_spaces_and_newlines(
    <<c::utf8, rest::binary>>,
    acc
  ) when is_utf8_space_like_char(c) do
    do_split_leading_spaces_and_newlines(rest, [c | acc])
  end

  defp do_split_leading_spaces_and_newlines(rest, acc) do
    {list_to_utf8_binary(Enum.reverse(acc)), rest}
  end

  @doc """
  Replaces excess spaces and lines with a replacement string, typically just a single space.

  The usecase for this is to ingest user input which may contain multiple spaces before, between and
  after the main content of the string.

  From experience, users may copy their data from applications which include normally invisible
  space or newline characters that cause problems on the server side.

  One may be asking, so what does this do differently than `String.trim/1`? Truncation.

  Usage:

      truncate_spaces(my_string)
      truncate_spaces("    ") #=> ""
      truncate_spaces("  Word  ") #=> "Word"
      truncate_spaces(" These   are\\nmultiple   spaces or\r\nlines") #=> "These are multiple spaces or lines"

  """
  @spec truncate_spaces(bin::String.t(), replacement::String.t()) :: String.t()
  def truncate_spaces(bin, replacement \\ " ") do
    do_truncate_spaces(bin, replacement)
  end

  defp do_truncate_spaces(bin, replacement, state \\ :start, acc \\ [])

  defp do_truncate_spaces(<<>>, _replacement, _, acc) do
    IO.iodata_to_binary(Enum.reverse(acc))
  end

  defp do_truncate_spaces(
    <<c1::utf8, c2::utf8, rest::binary>>,
    replacement,
    :start,
    acc
  ) when is_utf8_twochar_newline(c1, c2) do
    do_truncate_spaces(rest, replacement, :start, acc)
  end

  defp do_truncate_spaces(
    <<c::utf8, rest::binary>>,
    replacement,
    :start,
    acc
  ) when is_utf8_space_like_char(c) or is_utf8_newline_like_char(c) do
    do_truncate_spaces(rest, replacement, :start, acc)
  end

  defp do_truncate_spaces(<<rest::binary>>, replacement, :start, acc) do
    do_truncate_spaces(rest, replacement, :body, acc)
  end

  defp do_truncate_spaces(
    <<c1::utf8, c2::utf8, _rest::binary>> = rest,
    replacement,
    :body,
    acc
  ) when is_utf8_twochar_newline(c1, c2) do
    case split_leading_spaces_and_newlines(rest) do
      {_, "" = rest} ->
        do_truncate_spaces(rest, replacement, :body, acc)

      {_, rest} ->
        do_truncate_spaces(rest, replacement, :body, [replacement | acc])
    end
  end

  defp do_truncate_spaces(
    <<c::utf8, _rest::binary>> = rest,
    replacement,
    :body,
    acc
  ) when is_utf8_space_like_char(c) or is_utf8_newline_like_char(c) do
    case split_leading_spaces_and_newlines(rest) do
      {_, "" = rest} ->
        do_truncate_spaces(rest, replacement, :body, acc)

      {_, rest} ->
        do_truncate_spaces(rest, replacement, :body, [replacement | acc])
    end
  end

  defp do_truncate_spaces(<<c::utf8, rest::binary>>, replacement, :body, acc) do
    do_truncate_spaces(rest, replacement, :body, [<<c::utf8>> | acc])
  end

  @doc """
  String to Atom, unless it already is an atom in which case this will return as-is.

  Note this function uses `String.to_existing_atom/1` internally and may raise if the atom does not
  exist.
  """
  @spec string_to_atom(String.t()) :: atom()
  def string_to_atom(value) when is_atom(value) do
    value
  end

  def string_to_atom(value) when is_binary(value) do
    String.to_existing_atom(value)
  end

  @doc """
  Atom to GQL-styled enum value, typically it's just upcased.

  Usage:

      atom_to_gql_enum(value)
      atom_to_gql_enum(:my_enum_value) #=> "MY_ENUM_VALUE"

  """
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
  Returns the string is it contains any non-space or non-newline characters, nil otherwise.

  Usage:

      presence(value)
      presence("   ") #=> nil
      presence(" A ") #=> " A "

  """
  @spec presence(any()) :: nil | any()
  def presence(nil), do: nil

  def presence(""), do: nil

  def presence(value) when is_binary(value) do
    do_presence(value, value)
  end

  defp do_presence(<<>>, _org) do
    nil
  end

  defp do_presence(
    <<c1::utf8, c2::utf8, rest::binary>>,
    org
  ) when is_utf8_twochar_newline(c1, c2) do
    do_presence(rest, org)
  end

  defp do_presence(
    <<c::utf8, rest::binary>>,
    org
  ) when is_utf8_space_like_char(c) or is_utf8_newline_like_char(c) do
    do_presence(rest, org)
  end

  defp do_presence(
    <<_c::utf8, _rest::binary>>,
    org
  ) do
    org
  end

  @spec is_present?(binary()) :: boolean()
  def is_present?(value) do
    not is_nil(presence(value))
  end

  @spec is_blank?(binary()) :: boolean()
  def is_blank?(value) do
    is_nil(presence(value))
  end

  @doc """
  Scans the given list and returns the first element that evaluates &is_present?/1 to true

  Args:
  * `list` - the list to scan

  Returns:
  * `element` - the element that was present, or nil if nothing was found
  """
  @spec first_present(list()) :: any()
  def first_present(list) when is_list(list) do
    Enum.find(list, &is_present?/1)
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

  @spec identify_casing(String.t()) :: :none | :upcase | :downcase | :mixed
  def identify_casing(str) do
    do_identify_casing(str, :none)
  end

  defp do_identify_casing(<<>>, casing) do
    casing
  end

  defp do_identify_casing(
    <<c::utf8, rest::binary>>,
    casing
  ) when c >= ?A and c <= ?Z and casing in [:none, :upcase] do
    do_identify_casing(rest, :upcase)
  end

  defp do_identify_casing(
    <<c::utf8, rest::binary>>,
    casing
  ) when c >= ?a and c <= ?z and casing in [:none, :downcase] do
    do_identify_casing(rest, :downcase)
  end

  defp do_identify_casing(
    <<_c::utf8, rest::binary>>,
    _
  ) do
    do_identify_casing(rest, :mixed)
  end

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
  def stream_binary_chunks(
    bin,
    chunk_size
  ) when is_binary(bin) and is_integer(chunk_size) and chunk_size > 0 do
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
  def is_all_numeric?(<<>>), do: false
  def is_all_numeric?(rest) when is_binary(rest), do: do_is_all_numeric?(rest)

  defp do_is_all_numeric?(<<>>), do: true
  defp do_is_all_numeric?(<<c::utf8, rest::binary>>) when c in ?0..?9 do
    do_is_all_numeric?(rest)
  end
  defp do_is_all_numeric?(<<_c::utf8, _rest::binary>>), do: false

  @doc """
  Are all characters in the given string letters?
  """
  @spec is_all_alpha?(String.t()) :: boolean()
  def is_all_alpha?(<<>>), do: false
  def is_all_alpha?(rest) when is_binary(rest), do: do_is_all_alpha?(rest)

  defp do_is_all_alpha?(<<>>), do: true
  defp do_is_all_alpha?(<<c::utf8, rest::binary>>) when c in ?A..?Z or c in ?a..?z do
    do_is_all_alpha?(rest)
  end
  defp do_is_all_alpha?(<<_c::utf8, _rest::binary>>), do: false

  @doc """
  Are all characters in the given string numbers or letters?
  """
  @spec is_all_alpha_numeric?(String.t()) :: boolean
  def is_all_alpha_numeric?(<<>>), do: false
  def is_all_alpha_numeric?(rest) when is_binary(rest), do: do_is_all_alpha_numeric?(rest)

  defp do_is_all_alpha_numeric?(<<>>), do: true
  defp do_is_all_alpha_numeric?(<<c::utf8, rest::binary>>) when c in ?0..?9,
    do: is_all_alpha_numeric?(rest)
  defp do_is_all_alpha_numeric?(<<c::utf8, rest::binary>>) when c in ?A..?Z or c in ?a..?z,
    do: do_is_all_alpha_numeric?(rest)
  defp do_is_all_alpha_numeric?(<<_c::utf8, _rest::binary>>), do: false

  @doc """
  Strips any non-alpha or non-digit characters from the string.

  If you need only digits, use `normalize_numeric/1` instead
  If you need only letters, use `normalize_alpha/1` instead
  """
  @spec normalize_alpha_numeric(String.t()) :: String.t()
  def normalize_alpha_numeric(str) when is_binary(str) do
    IO.iodata_to_binary(do_normalize_alpha_numeric(str))
  end

  defp do_normalize_alpha_numeric(<<>>) do
    []
  end

  defp do_normalize_alpha_numeric(
    <<c::utf8, rest::binary>>
  ) when c in ?0..?9 or c in ?A..?Z or c in ?a..?z do
    [c | do_normalize_alpha_numeric(rest)]
  end

  defp do_normalize_alpha_numeric(<<_, rest::binary>>) do
    do_normalize_alpha_numeric(rest)
  end

  @doc """
  Strips any non-letter character from the string
  """
  @spec normalize_alpha(String.t()) :: String.t()
  def normalize_alpha(str) do
    IO.iodata_to_binary(do_normalize_alpha(str))
  end

  defp do_normalize_alpha(<<>>) do
    []
  end

  defp do_normalize_alpha(<<c::utf8, rest::binary>>) when c in ?A..?Z or c in ?a..?z do
    [c | do_normalize_alpha(rest)]
  end

  defp do_normalize_alpha(<<_, rest::binary>>) do
    do_normalize_alpha(rest)
  end

  @doc """
  Strips any non-digit character from the string
  """
  @spec normalize_numeric(String.t()) :: String.t()
  def normalize_numeric(str) do
    IO.iodata_to_binary(do_normalize_numeric(str))
  end

  defp do_normalize_numeric(<<>>) do
    []
  end

  defp do_normalize_numeric(<<c::utf8, rest::binary>>) when c in ?0..?9 do
    [c | do_normalize_numeric(rest)]
  end

  defp do_normalize_numeric(<<_, rest::binary>>) do
    do_normalize_numeric(rest)
  end

  @doc """
  Given an alpha-string, this function will change all letters to their telephone mnemonic
  equivalent.

  Usage:

      tn_mnemonic_to_string(str)
      tn_mnemonic_to_string("MORTAR") #=> "667827"

  """
  @spec tn_mnemonic_to_string(String.t()) :: String.t()
  def tn_mnemonic_to_string(number) when is_binary(number) do
    IO.iodata_to_binary(do_tn_mnemonic_to_string(number))
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

  defp do_tn_mnemonic_to_string(<<>>) do
    []
  end

  for {letter, number} <- mnemonic_map do
    defp do_tn_mnemonic_to_string(<<unquote(letter), rest::binary>>) do
      [unquote(number) | do_tn_mnemonic_to_string(rest)]
    end
  end

  defp do_tn_mnemonic_to_string(<<c::utf8, rest::binary>>) do
    [<<c::utf8>> | do_tn_mnemonic_to_string(rest)]
  end
end
