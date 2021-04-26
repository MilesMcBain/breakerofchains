# base pipe works

    Code
      source_tokens
    Output
               value row column       type
      1      library   1      1     symbol
      2            (   1      8    bracket
      3        dplyr   1      9     symbol
      4            )   1     14    bracket
      5           \n   1     15 whitespace
      6       mtcars   2      1     symbol
      7                2      7 whitespace
      8            |   2      8   operator
      9            >   2      9   operator
      10          \n   2     10 whitespace
      11     summary   3      1     symbol
      12           (   3      8    bracket
      13           )   3      9    bracket
      14        \n\n   3     10 whitespace
      15    starwars   5      1     symbol
      16               5      9 whitespace
      17           |   5     10   operator
      18           >   5     11   operator
      19          \n   5     12 whitespace
      20    group_by   6      1     symbol
      21           (   6      9    bracket
      22     species   6     10     symbol
      23           ,   6     17      comma
      24               6     18 whitespace
      25         sex   6     19     symbol
      26           )   6     22    bracket
      27               6     23 whitespace
      28           |   6     24   operator
      29           >   6     25   operator
      30          \n   6     26 whitespace
      31      select   7      1     symbol
      32           (   7      7    bracket
      33      height   7      8     symbol
      34           ,   7     14      comma
      35               7     15 whitespace
      36        mass   7     16     symbol
      37           )   7     20    bracket
      38               7     21 whitespace
      39           |   7     22   operator
      40           >   7     23   operator
      41          \n   7     24 whitespace
      42   summarise   8      1     symbol
      43           (   8     10    bracket
      44          \n   8     11 whitespace
      45      height   9      1     symbol
      46               9      7 whitespace
      47           =   9      8   operator
      48               9      9 whitespace
      49        mean   9     10     symbol
      50           (   9     14    bracket
      51      height   9     15     symbol
      52           ,   9     21      comma
      53               9     22 whitespace
      54       na.rm   9     23     symbol
      55               9     28 whitespace
      56           =   9     29   operator
      57               9     30 whitespace
      58        TRUE   9     31    keyword
      59           )   9     35    bracket
      60           ,   9     36      comma
      61          \n   9     37 whitespace
      62        mass  10      1     symbol
      63              10      5 whitespace
      64           =  10      6   operator
      65              10      7 whitespace
      66        mean  10      8     symbol
      67           (  10     12    bracket
      68        mass  10     13     symbol
      69           ,  10     17      comma
      70              10     18 whitespace
      71       na.rm  10     19     symbol
      72              10     24 whitespace
      73           =  10     25   operator
      74              10     26 whitespace
      75        TRUE  10     27    keyword
      76           )  10     31    bracket
      77          \n  10     32 whitespace
      78           )  11      1    bracket
      79              11      2 whitespace
      80           |  11      3   operator
      81           >  11      4   operator
      82          \n  11      5 whitespace
      83      ggplot  12      1     symbol
      84           (  12      7    bracket
      85         aes  12      8     symbol
      86           (  12     11    bracket
      87           x  12     12     symbol
      88              12     13 whitespace
      89           =  12     14   operator
      90              12     15 whitespace
      91      height  12     16     symbol
      92           ,  12     22      comma
      93              12     23 whitespace
      94           y  12     24     symbol
      95              12     25 whitespace
      96           =  12     26   operator
      97              12     27 whitespace
      98        mass  12     28     symbol
      99           )  12     32    bracket
      100          )  12     33    bracket
      101             12     34 whitespace
      102          +  12     35   operator
      103         \n  12     36 whitespace
      104 geom_point  13      1     symbol
      105          (  13     11    bracket
      106          )  13     12    bracket
      107             13     13 whitespace
      108          |  13     14   operator
      109          >  13     15   operator
      110         \n  13     16 whitespace
      111          .  14      1     symbol
      112         [[  14      2    bracket
      113          1  14      4     number
      114         ]]  14      5    bracket

---

    Code
      polyfill_base_pipe(source_tokens)
    Output
               value row column       type
      1      library   1      1     symbol
      2            (   1      8    bracket
      3        dplyr   1      9     symbol
      4            )   1     14    bracket
      5           \n   1     15 whitespace
      6       mtcars   2      1     symbol
      7                2      7 whitespace
      8           |>   2      8   operator
      10          \n   2     10 whitespace
      11     summary   3      1     symbol
      12           (   3      8    bracket
      13           )   3      9    bracket
      14        \n\n   3     10 whitespace
      15    starwars   5      1     symbol
      16               5      9 whitespace
      17          |>   5     10   operator
      19          \n   5     12 whitespace
      20    group_by   6      1     symbol
      21           (   6      9    bracket
      22     species   6     10     symbol
      23           ,   6     17      comma
      24               6     18 whitespace
      25         sex   6     19     symbol
      26           )   6     22    bracket
      27               6     23 whitespace
      28          |>   6     24   operator
      30          \n   6     26 whitespace
      31      select   7      1     symbol
      32           (   7      7    bracket
      33      height   7      8     symbol
      34           ,   7     14      comma
      35               7     15 whitespace
      36        mass   7     16     symbol
      37           )   7     20    bracket
      38               7     21 whitespace
      39          |>   7     22   operator
      41          \n   7     24 whitespace
      42   summarise   8      1     symbol
      43           (   8     10    bracket
      44          \n   8     11 whitespace
      45      height   9      1     symbol
      46               9      7 whitespace
      47           =   9      8   operator
      48               9      9 whitespace
      49        mean   9     10     symbol
      50           (   9     14    bracket
      51      height   9     15     symbol
      52           ,   9     21      comma
      53               9     22 whitespace
      54       na.rm   9     23     symbol
      55               9     28 whitespace
      56           =   9     29   operator
      57               9     30 whitespace
      58        TRUE   9     31    keyword
      59           )   9     35    bracket
      60           ,   9     36      comma
      61          \n   9     37 whitespace
      62        mass  10      1     symbol
      63              10      5 whitespace
      64           =  10      6   operator
      65              10      7 whitespace
      66        mean  10      8     symbol
      67           (  10     12    bracket
      68        mass  10     13     symbol
      69           ,  10     17      comma
      70              10     18 whitespace
      71       na.rm  10     19     symbol
      72              10     24 whitespace
      73           =  10     25   operator
      74              10     26 whitespace
      75        TRUE  10     27    keyword
      76           )  10     31    bracket
      77          \n  10     32 whitespace
      78           )  11      1    bracket
      79              11      2 whitespace
      80          |>  11      3   operator
      82          \n  11      5 whitespace
      83      ggplot  12      1     symbol
      84           (  12      7    bracket
      85         aes  12      8     symbol
      86           (  12     11    bracket
      87           x  12     12     symbol
      88              12     13 whitespace
      89           =  12     14   operator
      90              12     15 whitespace
      91      height  12     16     symbol
      92           ,  12     22      comma
      93              12     23 whitespace
      94           y  12     24     symbol
      95              12     25 whitespace
      96           =  12     26   operator
      97              12     27 whitespace
      98        mass  12     28     symbol
      99           )  12     32    bracket
      100          )  12     33    bracket
      101             12     34 whitespace
      102          +  12     35   operator
      103         \n  12     36 whitespace
      104 geom_point  13      1     symbol
      105          (  13     11    bracket
      106          )  13     12    bracket
      107             13     13 whitespace
      108         |>  13     14   operator
      110         \n  13     16 whitespace
      111          .  14      1     symbol
      112         [[  14      2    bracket
      113          1  14      4     number
      114         ]]  14      5    bracket

