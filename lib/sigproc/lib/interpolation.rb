module SigProc
class Interpolation
  # Linear Interpolation Equation:
  #
  #        (x3 - x1)(y2 - y1)
  #  y3 =  ------------------  + y1
  #            (x2 - x1)
  #
  def self.linear x1, y1, x2, y2, x3
    y3 = ((x3 - x1) * (y2 - y1)) / (x2 - x1);
    y3 += y1;
    return y3;
  end
end
end
