try
  while true
    try
      while true
      end
    catch e
      println("🚨 INNER CAUGHT")
    end
  end
catch e
  println("⏰ OUTER CAUGHT")
end