local Vector = {}

Vector.x = 0
Vector.y = 0

Vector.mt = {}
setmetatable(Vector, mt)

function Vector.mt.__add(a, b)
   if type(a) == "table" and type(b) == "table" then
      -- two vectors, so perform vector addition
      local result = Vector.new()
      result.x = a.x + b.x
      result.y = a.y + b.y
      return result
   end
end

function Vector.mt.__sub(a, b)
   if type(a) == "table" and type(b) == "table" then
      -- two vectors, so perform vector subtraction
      local result = Vector.new()
      result.x = a.x - b.x
      result.y = a.y - b.y
      return result
   end
end

function Vector.mt.__mul(vector, scalar)
   if type(vector) == "table" and type(scalar) == "number" then
      local result = Vector.new()
      result.x = vector.x * scalar
      result.y = vector.y * scalar
      return result
   end
end

function Vector:length()
   return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:normalize()
   local result = Vector.new()
   local length = self:length()
   if length <= 0 then
      return result
   end
   result.x = self.x / length
   result.y = self.y / length
   return result
end

Vector.mt.__index = Vector

function Vector.new(x, y)
   local new_vector = {}
   setmetatable(new_vector, Vector.mt)
   if x then
      new_vector.x = x
   end
   if y then
      new_vector.y = y
   end
   return new_vector
end

return Vector
