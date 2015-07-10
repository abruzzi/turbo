module HashRecursiveMerge
  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
        oldval.class == self.class ? oldval.rmerge!(newval) : newval
    end
  end

  def rmerge(other_hash)
    r = {}
    merge(other_hash)  do |key, oldval, newval|
      r[key] = oldval.class == self.class ? oldval.rmerge(newval) : newval
    end
  end
end

class Hash
  include HashRecursiveMerge
end