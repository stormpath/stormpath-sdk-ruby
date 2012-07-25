class Hash

  # implementation borrowed from the vine project at
  # https://github.com/guangnan/vine/blob/master/lib/vine.rb
  def access(path, separator)
    ret = self
    path.split(separator).each do |p|
      if p.to_i.to_s == p
        ret = ret[p.to_i]
      else
        ret = ret[p.to_s] || ret[p.to_sym]
      end
      break unless ret
    end
    ret
  end
end
