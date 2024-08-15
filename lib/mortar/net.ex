defmodule Mortar.Net do
  @type hostname :: String.t()

  @type socket_port :: integer()

  @type ip_address :: :inet.ip_address()

  @type dns_record :: any()

  @spec guess_host_fqdn :: {:ok, String.t()}
  def guess_host_fqdn do
    with {:ok, hostname} <- :inet.gethostname(),
         {:ok, hostent} <- :inet.gethostbyname(hostname) do
      {:hostent, fqdn, _aliases, :inet, _, _addresses} = hostent
      {:ok, to_string(fqdn)}
    end
  end

  def guess_host_fqdn! do
    {:ok, fqdn} = guess_host_fqdn()
    fqdn
  end

  def integer_to_ip_address4(value) when is_integer(value) do
    <<
      a::integer-size(8),
      b::integer-size(8),
      c::integer-size(8),
      d::integer-size(8)
    >> = <<value::little-integer-size(32)>>
    {a, b, c, d}
  end

  def string_to_ip_address(value) when is_binary(value) do
    {:ok, ip} = :inet.parse_address(to_charlist(value))
    ip
  end

  def ip_to_string(tup) when is_tuple(tup) do
    tup
    |> :inet.ntoa()
    |> to_string()
  end

  def maybe_ip_to_string(nil) do
    nil
  end

  def maybe_ip_to_string(tup) when is_tuple(tup) do
    ip_to_string(tup)
  end

  @rr_types ~w[
    a
    aaaa
    caa
    cname
    gid
    hinfo
    ns
    mb
    md
    mg
    mf
    minfo
    mx
    naptr
    null
    ptr
    soa
    spf
    srv
    txt
    uid
    uinfo
    unspec
    uri
    wks
    any
  ]a

  @class_types ~w[
    in
    chaos
    hs
    any
  ]a

  def cast_dns_rr(integer) when is_integer(integer) do
    {:ok, integer}
  end

  for type <- @rr_types do
    def cast_dns_rr(unquote(type)) do
      {:ok, unquote(type)}
    end
  end

  for type <- @rr_types do
    type_s = Atom.to_string(type)
    def cast_dns_rr(unquote(type_s)) do
      {:ok, unquote(type)}
    end
  end

  def cast_dns_rr(_) do
    :error
  end

  for type <- @class_types do
    def cast_dns_class(unquote(type)) do
      {:ok, unquote(type)}
    end
  end

  for type <- @class_types do
    type_s = Atom.to_string(type)
    def cast_dns_class(unquote(type_s)) do
      {:ok, unquote(type)}
    end
  end

  def cast_dns_class(_) do
    :error
  end

  @doc """
  Wrapper around :inet_res.resolve, returns a dns_rec (as a keyword list)

  Args:
  * `name` - the hostname or ip address to lookup
  * `class` - the dns class
  * `type` - the record type
  * `options` - inet_res resolve options
  * `timeout` - timeout
  """
  @spec dns_resolve_raw(
          String.t() | :inet.ip_address(),
          :inet_res.dns_class(),
          :inet_res.rr_type(),
          [:inet_res.res_option()],
          :inet_res.timeout()
        ) :: {:ok, Keyword.t()}
           | {:error, term}
  def dns_resolve_raw(name, class, type, options \\ [], timeout \\ :infinity) do
    name
    |> to_charlist()
    |> :inet_res.resolve(class, type, options, timeout)
    |> case do
      {:ok, rec} ->
        {:ok, rec}

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Wrapper around :inet_res.resolve, returns a dns_rec (as a keyword list)

  Args:
  * `name` - the hostname or ip address to lookup
  * `class` - the dns class
  * `type` - the record type
  * `options` - inet_res resolve options
  * `timeout` - timeout
  """
  @spec dns_resolve(
          String.t() | :inet.ip_address(),
          :inet_res.dns_class(),
          :inet_res.rr_type(),
          [:inet_res.res_option()],
          :inet_res.timeout()
        ) :: {:ok, Keyword.t()}
           | {:error, term}
  def dns_resolve(name, class, type, options \\ [], timeout \\ :infinity) do
    case dns_resolve_raw(name, class, type, options, timeout) do
      {:ok, rec} ->
        msg =
          :inet_dns.msg(rec)
          |> Enum.map(fn
            {:header, header} ->
              {:header, :inet_dns.header(header)}

            {:qdlist, list} ->
              {:qdlist, Enum.map(list, &:inet_dns.dns_query/1) }

            {key, list} when key in [:anlist, :nslist, :arlist] ->
              {key, Enum.map(list, &:inet_dns.rr/1)}
          end)

        {:ok, msg}

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Re-implementation of inet_res.lookup, however this will return the errors
  from the resolve stage as well.

  Args:
  * `name` - the hostname or ip address to lookup
  * `class` - the dns class
  * `type` - the record type
  * `options` - inet_res resolve options
  * `timeout` - timeout
  """
  @spec dns_lookup(
      String.t() | :inet.ip_address(),
      :inet_res.dns_class(),
      :inet_res.rr_type(),
      [:inet_res.res_option()],
      :inet_res.timeout()
    ) :: {:ok, [Keyword.t()]}
       | {:error, term}
  def dns_lookup(name, class, type, options \\ [], timeout \\ :infinity) do
    case dns_resolve(name, class, type, options, timeout) do
      {:ok, rec} ->
        data =
          Enum.reduce(rec[:anlist], [], fn answer, acc ->
            if (class == :any or answer[:class] == class) and
               (type == :any or answer[:type] == type) do
              [answer | acc]
            else
              acc
            end
          end)

        {:ok, data}

      {:error, _} = err ->
        err
    end
  end

  @spec determine_timeout(Keyword.t(), Keyword.t(), atom | integer) ::
          atom | integer
  def determine_timeout(caller_options, config_options, default) do
    caller_options[:timeout] ||
    config_options[:timeout] ||
    default
  end

  @spec parse_nameservers([hostname | {hostname, socket_port} | {ip_address, socket_port}]) :: [{ip_address, socket_port}]
  def parse_nameservers(nameservers) when is_list(nameservers) do
    nameservers
    |> Enum.map(fn
      {ip, port} when is_tuple(ip) ->
        {ip, port}

      {hostname, port} when is_binary(hostname) ->
        {hostname, port}

      str when is_binary(str) ->
        case String.split(str, ":") do
          [hostname, ""] ->
            {hostname, 53}

          [hostname, port] ->
            {hostname, String.to_integer(port)}

          [hostname] ->
            {hostname, 53}
        end
    end)
  end

  @spec prepare_nameservers([hostname | {hostname, socket_port} | {ip_address, socket_port}]) :: [{ip_address, socket_port}]
  def prepare_nameservers(nameservers) when is_list(nameservers) do
    nameservers
    |> parse_nameservers()
    |> Enum.flat_map(fn
      {ip, port} when is_tuple(ip) ->
        [{ip, port}]

      {hostname, port} when is_binary(hostname) ->
        {:ok, {:hostent, _, _, _, _, nameservers}} =
          hostname
          |> to_charlist()
          |> :inet.gethostbyname()

        Enum.map(nameservers, fn ip ->
          {ip, port}
        end)
    end)
    |> Enum.uniq()
  end
end
