# What to do

Derive DateTime from Time expression with Natural language

# Sample

    jajp = Horai::JaJP.new

    time = jajp.parse("1999年")    
    => Fri, 01 Jan 1999 00:00:00 +0900

    time = jajp.parse("1月")    
    => Sun, 01 Jan 2012 00:00:00 +0900

    time = jajp.parse("1時半")    
    => Thu, 26 Apr 2012 01:30:00 +0900

    time = jajp.parse("1分半後")    
    => Thu, 26 Apr 2012 14:11:34 +0900

    time = jajp.parse("5時間半と1分半後")    
    => Thu, 26 Apr 2012 19:41:38 +0900

    time = jajp.parse("夜の8時に")    
    => Thu, 26 Apr 2012 20:00:00 +0900

    time = jajp.parse("午後一時に")    
    => Thu, 26 Apr 2012 13:00:00 +0900

    time = jajp.parse("PM1時に")    
    => Thu, 26 Apr 2012 13:00:00 +0900

    time = jajp.parse("rpm 6時に")    
    => Thu, 26 Apr 2012 06:00:00 +0900

    time = jajp.parse("10日の正午に")    
    => Tue, 10 Apr 2012 12:00:00 +0900

    time = jajp.parse("10:20")    
    => Thu, 26 Apr 2012 10:20:00 +0900

    time = jajp.parse("10:20:30")    
    => Thu, 26 Apr 2012 10:20:30 +0900

    time = jajp.parse("10/20")    
    => Sat, 20 Oct 2012 00:00:00 +0900

    time = jajp.parse("2000/10/20")    
    => Fri, 20 Oct 2000 00:00:00 +0900

    time = jajp.parse("10/10/20")    
    => Wed, 20 Oct 2010 00:00:00 +0900

    time = jajp.parse("2000/10/20 12:30:40")    
    => Fri, 20 Oct 2000 12:30:40 +0900

    time = jajp.parse("10年")    
    => Fri, 01 Jan 2010 00:00:00 +0900

    time = jajp.parse("30年")    
    => Tue, 01 Jan 2030 00:00:00 +0900

    time = jajp.parse("90年")    
    => Mon, 01 Jan 1990 00:00:00 +0900

    time = jajp.parse("来年")    
    => Tue, 01 Jan 2013 00:00:00 +0900

    time = jajp.parse("来月")    
    => Tue, 01 May 2012 00:00:00 +0900

    time = jajp.parse("明日")    
    => Fri, 27 Apr 2012 00:00:00 +0900

    time = jajp.parse("明後日")    
    => Sat, 28 Apr 2012 00:00:00 +0900

    time = jajp.parse("昨日")    
    => Wed, 25 Apr 2012 00:00:00 +0900

    time = jajp.parse("10年後の8月")    
    => Mon, 01 Aug 2022 00:00:00 +0900

    time = jajp.parse("10分後")    
    => Thu, 26 Apr 2012 14:20:27 +0900

    time = jajp.parse("10日後")    
    => Sun, 06 May 2012 14:10:27 +0900

    time = jajp.parse("明日の10時")    
    => Fri, 27 Apr 2012 10:00:00 +0900

    time = jajp.parse("明日の10:20:30")    
    => Fri, 27 Apr 2012 10:20:30 +0900

    time = jajp.parse("明日の午後5時")    
    => Fri, 27 Apr 2012 17:00:00 +0900

    time = jajp.parse("明日の正午")    
    => Fri, 27 Apr 2012 12:00:00 +0900

    time = jajp.parse("3日後の12時")    
    => Sun, 29 Apr 2012 12:00:00 +0900

    time = jajp.parse("3日後の12時45分")    
    => Sun, 29 Apr 2012 12:45:00 +0900

    time = jajp.parse("3日後の12:45:55")    
    => Sun, 29 Apr 2012 12:45:55 +0900

    time = jajp.parse("3日12時間45分後")    
    => Mon, 30 Apr 2012 02:55:27 +0900

    time = jajp.parse("1時間半後")    
    => Thu, 26 Apr 2012 15:40:27 +0900

    time = jajp.parse("1分半後")    
    => Thu, 26 Apr 2012 14:11:57 +0900

    time = jajp.parse("5時間半と1分半後")    
    => Thu, 26 Apr 2012 19:42:03 +0900
