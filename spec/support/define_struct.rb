module DefineStruct
  def from_hash(hash = {})
    values = members.map do |attr|
      val = hash[attr]
      val.is_a?(Hash) ? define_struct(*val.keys).from_hash(val) : val
    end
    new(*values)
  end

  def define_struct(*attrs)
    Struct.new(*attrs) do
      extend DefineStruct
    end
  end
end

def def_struct(*attrs)
  Struct.new(*attrs) do
    extend DefineStruct
  end
end

def struct_from_hash(hash)
  def_struct(*hash.keys).from_hash(hash)
end
