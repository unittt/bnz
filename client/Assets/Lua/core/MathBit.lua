MathBit = {}
local modf = math.modf

function MathBit.__andBit(left,right)  
    return (left == 1 and right == 1) and 1 or 0      
end  
  
function MathBit.__orBit(left, right)  
    return (left == 1 or right == 1) and 1 or 0  
end  
  
function MathBit.__xorBit(left, right)  
    return (left + right) == 1 and 1 or 0  
end  
  
function MathBit.__base(left, right, op)  
    if left < right then  
        left, right = right, left  
    end  
    local res = 0  
    local shift = 1  
    while left ~= 0 do  
        local ra = left % 2  
        local rb = right % 2  
        res = shift * op(ra,rb) + res
        shift = shift * 2
        left = modf( left / 2)
        right = modf( right / 2)
    end  
    return res
end
  
function MathBit.andOp(left, right)
    return MathBit.__base(left, right, MathBit.__andBit)
end  
  
function MathBit.xorOp(left, right)  
    return MathBit.__base(left, right, MathBit.__xorBit)
end  
  
function MathBit.orOp(left, right)  
    return MathBit.__base(left, right, MathBit.__orBit)
end  
  
function MathBit.notOp(left)  
    return left > 0 and -(left + 1) or -left - 1
end  
  
function MathBit.lShiftOp(left, num)
    return left * (2 ^ num)  
end  
  
function MathBit.rShiftOp(left,num)
    return math.floor(left / (2 ^ num))
end

return MathBit