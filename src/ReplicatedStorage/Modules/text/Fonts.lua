local fonts = {}

fonts.FontTable = {
	MinecraftFont = {
		FontData = [[
		info face="MinecraftV[Somethung]" size=18 bold=0 italic=0 charset="32-126,198" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,1,1,1 spacing=1,1 outline=0
common lineHeight=23 base=16 scaleW=135 scaleH=135 pages=1 packed=0 alphaChnl=0 redChnl=4 greenChnl=4 blueChnl=4
page id=0 file="MinecraftV[Somethung].png"
chars count=96
char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=8 page=0 chnl=15
char id=33 x=15 y=34 width=4 height=16 xoffset=0 yoffset=1 xadvance=5 page=0 chnl=15
char id=34 x=85 y=129 width=8 height=6 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=35 x=72 y=85 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=36 x=72 y=102 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=37 x=72 y=34 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=38 x=72 y=119 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=39 x=15 y=103 width=4 height=6 xoffset=0 yoffset=1 xadvance=5 page=0 chnl=15
char id=40 x=125 y=102 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=41 x=125 y=119 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=42 x=112 y=88 width=8 height=8 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=43 x=99 y=117 width=12 height=12 xoffset=0 yoffset=3 xadvance=13 page=0 chnl=15
char id=44 x=15 y=96 width=4 height=6 xoffset=0 yoffset=13 xadvance=5 page=0 chnl=15
char id=45 x=99 y=130 width=12 height=4 xoffset=0 yoffset=7 xadvance=13 page=0 chnl=15
char id=46 x=15 y=110 width=4 height=4 xoffset=0 yoffset=13 xadvance=5 page=0 chnl=15
char id=47 x=72 y=68 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=48 x=0 y=60 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=49 x=0 y=77 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=50 x=0 y=94 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=51 x=0 y=111 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=52 x=21 y=0 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=53 x=20 y=17 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=54 x=20 y=34 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=55 x=20 y=51 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=56 x=20 y=68 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=57 x=20 y=85 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=58 x=15 y=83 width=4 height=12 xoffset=0 yoffset=5 xadvance=5 page=0 chnl=15
char id=59 x=15 y=68 width=4 height=14 xoffset=0 yoffset=5 xadvance=5 page=0 chnl=15
char id=60 x=125 y=34 width=10 height=16 xoffset=0 yoffset=1 xadvance=11 page=0 chnl=15
char id=61 x=112 y=0 width=12 height=10 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=62 x=125 y=51 width=10 height=16 xoffset=0 yoffset=1 xadvance=11 page=0 chnl=15
char id=63 x=72 y=51 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=64 x=0 y=17 width=14 height=16 xoffset=0 yoffset=3 xadvance=15 page=0 chnl=15
char id=65 x=33 y=17 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=66 x=33 y=34 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=67 x=33 y=51 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=68 x=33 y=68 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=69 x=33 y=85 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=70 x=33 y=102 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=71 x=33 y=119 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=72 x=47 y=0 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=73 x=125 y=85 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=74 x=46 y=17 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=75 x=46 y=34 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=76 x=46 y=51 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=77 x=46 y=68 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=78 x=46 y=85 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=79 x=46 y=102 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=80 x=46 y=119 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=81 x=60 y=0 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=82 x=59 y=17 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=83 x=59 y=34 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=84 x=59 y=51 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=85 x=59 y=68 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=86 x=59 y=85 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=87 x=59 y=102 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=88 x=59 y=119 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=89 x=73 y=0 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=90 x=72 y=17 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=91 x=112 y=54 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=92 x=86 y=0 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=93 x=112 y=71 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=94 x=112 y=11 width=12 height=8 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=95 x=0 y=128 width=12 height=4 xoffset=0 yoffset=15 xadvance=13 page=0 chnl=15
char id=96 x=112 y=114 width=6 height=6 xoffset=0 yoffset=1 xadvance=7 page=0 chnl=15
char id=97 x=85 y=77 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=98 x=20 y=102 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=99 x=85 y=90 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=100 x=20 y=119 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=101 x=85 y=103 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=102 x=125 y=0 width=10 height=16 xoffset=0 yoffset=1 xadvance=11 page=0 chnl=15
char id=103 x=85 y=17 width=12 height=14 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=104 x=34 y=0 width=12 height=16 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=105 x=15 y=17 width=4 height=16 xoffset=0 yoffset=1 xadvance=5 page=0 chnl=15
char id=106 x=0 y=41 width=12 height=18 xoffset=0 yoffset=1 xadvance=13 page=0 chnl=15
char id=107 x=125 y=17 width=10 height=16 xoffset=0 yoffset=1 xadvance=11 page=0 chnl=15
char id=108 x=112 y=97 width=6 height=16 xoffset=0 yoffset=1 xadvance=7 page=0 chnl=15
char id=109 x=85 y=116 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=110 x=99 y=0 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=111 x=99 y=13 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=112 x=85 y=32 width=12 height=14 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=113 x=85 y=47 width=12 height=14 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=114 x=99 y=26 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=115 x=99 y=39 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=116 x=125 y=68 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=117 x=99 y=52 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=118 x=99 y=65 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=119 x=99 y=78 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=120 x=99 y=91 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=121 x=85 y=62 width=12 height=14 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=122 x=99 y=104 width=12 height=12 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=123 x=112 y=20 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=124 x=15 y=51 width=4 height=16 xoffset=0 yoffset=1 xadvance=5 page=0 chnl=15
char id=125 x=112 y=37 width=8 height=16 xoffset=0 yoffset=1 xadvance=9 page=0 chnl=15
char id=126 x=0 y=34 width=14 height=6 xoffset=0 yoffset=1 xadvance=15 page=0 chnl=15
char id=198 x=0 y=0 width=20 height=16 xoffset=0 yoffset=1 xadvance=21 page=0 chnl=15


]],

		FontMap = "rbxassetid://103276972966692",  

		DisplaySize = 29, -- native lineHeight is 18
	},

	ComicSans = {
		FontData = [[

		info face="Comic Sans MS" size=18 bold=0 italic=0 charset="32-126,198" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,1,1,1 spacing=1,1 outline=0
common lineHeight=25 base=20 scaleW=143 scaleH=143 pages=1 packed=0 alphaChnl=0 redChnl=4 greenChnl=4 blueChnl=4
page id=0 file="Comic Sans MS (ex).png"
chars count=96
char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=6 page=0 chnl=15
char id=33 x=106 y=126 width=4 height=17 xoffset=0 yoffset=5 xadvance=5 page=0 chnl=15
char id=34 x=68 y=135 width=7 height=8 xoffset=0 yoffset=5 xadvance=8 page=0 chnl=15
char id=35 x=0 y=90 width=17 height=16 xoffset=-1 yoffset=5 xadvance=16 page=0 chnl=15
char id=36 x=54 y=67 width=12 height=20 xoffset=0 yoffset=4 xadvance=13 page=0 chnl=15
char id=37 x=23 y=17 width=15 height=16 xoffset=0 yoffset=5 xadvance=15 page=0 chnl=15
char id=38 x=23 y=105 width=14 height=17 xoffset=-1 yoffset=5 xadvance=12 page=0 chnl=15
char id=39 x=138 y=28 width=5 height=7 xoffset=1 yoffset=4 xadvance=7 page=0 chnl=15
char id=40 x=118 y=79 width=8 height=20 xoffset=0 yoffset=5 xadvance=7 page=0 chnl=15
char id=41 x=129 y=52 width=7 height=20 xoffset=0 yoffset=5 xadvance=7 page=0 chnl=15
char id=42 x=106 y=37 width=11 height=9 xoffset=-1 yoffset=5 xadvance=10 page=0 chnl=15
char id=43 x=118 y=39 width=10 height=9 xoffset=-1 yoffset=10 xadvance=9 page=0 chnl=15
char id=44 x=129 y=96 width=6 height=6 xoffset=0 yoffset=18 xadvance=5 page=0 chnl=15
char id=45 x=129 y=47 width=8 height=4 xoffset=0 yoffset=13 xadvance=8 page=0 chnl=15
char id=46 x=138 y=36 width=5 height=4 xoffset=0 yoffset=18 xadvance=5 page=0 chnl=15
char id=47 x=81 y=74 width=11 height=17 xoffset=-1 yoffset=5 xadvance=10 page=0 chnl=15
char id=48 x=39 y=63 width=13 height=16 xoffset=-1 yoffset=5 xadvance=11 page=0 chnl=15
char id=49 x=129 y=20 width=8 height=16 xoffset=0 yoffset=5 xadvance=9 page=0 chnl=15
char id=50 x=94 y=85 width=11 height=15 xoffset=0 yoffset=6 xadvance=11 page=0 chnl=15
char id=51 x=94 y=101 width=11 height=15 xoffset=0 yoffset=6 xadvance=11 page=0 chnl=15
char id=52 x=39 y=80 width=13 height=16 xoffset=-1 yoffset=5 xadvance=11 page=0 chnl=15
char id=53 x=81 y=20 width=11 height=17 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=54 x=81 y=38 width=11 height=17 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=55 x=39 y=97 width=13 height=16 xoffset=-1 yoffset=6 xadvance=11 page=0 chnl=15
char id=56 x=94 y=117 width=11 height=15 xoffset=0 yoffset=6 xadvance=11 page=0 chnl=15
char id=57 x=68 y=18 width=12 height=16 xoffset=0 yoffset=6 xadvance=11 page=0 chnl=15
char id=58 x=138 y=16 width=5 height=11 xoffset=0 yoffset=9 xadvance=6 page=0 chnl=15
char id=59 x=129 y=73 width=6 height=14 xoffset=-1 yoffset=9 xadvance=6 page=0 chnl=15
char id=60 x=129 y=37 width=8 height=9 xoffset=-1 yoffset=10 xadvance=7 page=0 chnl=15
char id=61 x=118 y=49 width=10 height=9 xoffset=-1 yoffset=10 xadvance=10 page=0 chnl=15
char id=62 x=94 y=133 width=9 height=10 xoffset=-1 yoffset=9 xadvance=7 page=0 chnl=15
char id=63 x=94 y=68 width=11 height=16 xoffset=-1 yoffset=6 xadvance=10 page=0 chnl=15
char id=64 x=0 y=55 width=17 height=17 xoffset=0 yoffset=5 xadvance=17 page=0 chnl=15
char id=65 x=54 y=51 width=13 height=15 xoffset=0 yoffset=6 xadvance=14 page=0 chnl=15
char id=66 x=68 y=52 width=12 height=16 xoffset=0 yoffset=5 xadvance=12 page=0 chnl=15
char id=67 x=68 y=103 width=12 height=15 xoffset=0 yoffset=6 xadvance=11 page=0 chnl=15
char id=68 x=39 y=45 width=13 height=17 xoffset=0 yoffset=5 xadvance=13 page=0 chnl=15
char id=69 x=54 y=88 width=12 height=17 xoffset=0 yoffset=5 xadvance=12 page=0 chnl=15
char id=70 x=54 y=106 width=12 height=17 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=71 x=23 y=69 width=14 height=17 xoffset=-1 yoffset=5 xadvance=13 page=0 chnl=15
char id=72 x=23 y=87 width=14 height=17 xoffset=0 yoffset=5 xadvance=14 page=0 chnl=15
char id=73 x=68 y=119 width=12 height=15 xoffset=-1 yoffset=6 xadvance=10 page=0 chnl=15
char id=74 x=39 y=114 width=13 height=16 xoffset=0 yoffset=6 xadvance=12 page=0 chnl=15
char id=75 x=68 y=69 width=12 height=16 xoffset=0 yoffset=6 xadvance=11 page=0 chnl=15
char id=76 x=68 y=0 width=12 height=17 xoffset=-1 yoffset=5 xadvance=10 page=0 chnl=15
char id=77 x=0 y=73 width=17 height=16 xoffset=0 yoffset=6 xadvance=16 page=0 chnl=15
char id=78 x=0 y=107 width=15 height=17 xoffset=0 yoffset=5 xadvance=15 page=0 chnl=15
char id=79 x=0 y=125 width=15 height=16 xoffset=0 yoffset=6 xadvance=15 page=0 chnl=15
char id=80 x=94 y=51 width=11 height=16 xoffset=-1 yoffset=5 xadvance=10 page=0 chnl=15
char id=81 x=0 y=35 width=18 height=19 xoffset=-1 yoffset=6 xadvance=16 page=0 chnl=15
char id=82 x=68 y=86 width=12 height=16 xoffset=0 yoffset=5 xadvance=12 page=0 chnl=15
char id=83 x=54 y=0 width=13 height=16 xoffset=0 yoffset=6 xadvance=13 page=0 chnl=15
char id=84 x=39 y=0 width=14 height=15 xoffset=0 yoffset=6 xadvance=13 page=0 chnl=15
char id=85 x=39 y=16 width=14 height=15 xoffset=0 yoffset=6 xadvance=14 page=0 chnl=15
char id=86 x=54 y=17 width=13 height=16 xoffset=0 yoffset=6 xadvance=12 page=0 chnl=15
char id=87 x=0 y=18 width=20 height=16 xoffset=0 yoffset=6 xadvance=19 page=0 chnl=15
char id=88 x=23 y=0 width=15 height=16 xoffset=-1 yoffset=6 xadvance=14 page=0 chnl=15
char id=89 x=54 y=34 width=13 height=16 xoffset=-1 yoffset=6 xadvance=12 page=0 chnl=15
char id=90 x=23 y=34 width=15 height=15 xoffset=-1 yoffset=6 xadvance=13 page=0 chnl=15
char id=91 x=118 y=120 width=8 height=19 xoffset=0 yoffset=6 xadvance=7 page=0 chnl=15
char id=92 x=106 y=65 width=10 height=16 xoffset=0 yoffset=6 xadvance=10 page=0 chnl=15
char id=93 x=129 y=0 width=8 height=19 xoffset=0 yoffset=6 xadvance=7 page=0 chnl=15
char id=94 x=118 y=59 width=10 height=6 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=95 x=23 y=64 width=15 height=4 xoffset=-2 yoffset=20 xadvance=12 page=0 chnl=15
char id=96 x=129 y=88 width=6 height=7 xoffset=0 yoffset=4 xadvance=11 page=0 chnl=15
char id=97 x=39 y=131 width=11 height=12 xoffset=-1 yoffset=10 xadvance=10 page=0 chnl=15
char id=98 x=81 y=92 width=11 height=16 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=99 x=118 y=0 width=10 height=12 xoffset=0 yoffset=10 xadvance=10 page=0 chnl=15
char id=100 x=81 y=109 width=11 height=16 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=101 x=106 y=13 width=11 height=11 xoffset=0 yoffset=10 xadvance=10 page=0 chnl=15
char id=102 x=81 y=126 width=10 height=17 xoffset=-1 yoffset=5 xadvance=10 page=0 chnl=15
char id=103 x=94 y=0 width=11 height=16 xoffset=-1 yoffset=10 xadvance=10 page=0 chnl=15
char id=104 x=81 y=56 width=11 height=17 xoffset=0 yoffset=5 xadvance=11 page=0 chnl=15
char id=105 x=138 y=0 width=5 height=15 xoffset=0 yoffset=6 xadvance=6 page=0 chnl=15
char id=106 x=23 y=123 width=9 height=20 xoffset=-2 yoffset=6 xadvance=8 page=0 chnl=15
char id=107 x=94 y=17 width=11 height=16 xoffset=0 yoffset=5 xadvance=10 page=0 chnl=15
char id=108 x=111 y=126 width=5 height=16 xoffset=0 yoffset=5 xadvance=5 page=0 chnl=15
char id=109 x=23 y=50 width=15 height=13 xoffset=0 yoffset=9 xadvance=14 page=0 chnl=15
char id=110 x=106 y=98 width=10 height=13 xoffset=0 yoffset=9 xadvance=10 page=0 chnl=15
char id=111 x=118 y=13 width=10 height=12 xoffset=0 yoffset=10 xadvance=10 page=0 chnl=15
char id=112 x=106 y=47 width=10 height=17 xoffset=0 yoffset=9 xadvance=10 page=0 chnl=15
char id=113 x=94 y=34 width=11 height=16 xoffset=-1 yoffset=10 xadvance=10 page=0 chnl=15
char id=114 x=118 y=66 width=9 height=12 xoffset=0 yoffset=10 xadvance=9 page=0 chnl=15
char id=115 x=106 y=112 width=10 height=13 xoffset=-1 yoffset=9 xadvance=9 page=0 chnl=15
char id=116 x=106 y=82 width=10 height=15 xoffset=-1 yoffset=7 xadvance=9 page=0 chnl=15
char id=117 x=106 y=0 width=11 height=12 xoffset=-1 yoffset=10 xadvance=10 page=0 chnl=15
char id=118 x=106 y=25 width=11 height=11 xoffset=-1 yoffset=10 xadvance=9 page=0 chnl=15
char id=119 x=39 y=32 width=14 height=12 xoffset=-1 yoffset=10 xadvance=13 page=0 chnl=15
char id=120 x=81 y=0 width=12 height=12 xoffset=-1 yoffset=9 xadvance=11 page=0 chnl=15
char id=121 x=68 y=35 width=12 height=16 xoffset=-2 yoffset=10 xadvance=10 page=0 chnl=15
char id=122 x=118 y=26 width=10 height=12 xoffset=0 yoffset=10 xadvance=10 page=0 chnl=15
char id=123 x=54 y=124 width=8 height=19 xoffset=-1 yoffset=5 xadvance=7 page=0 chnl=15
char id=124 x=33 y=123 width=4 height=20 xoffset=2 yoffset=4 xadvance=8 page=0 chnl=15
char id=125 x=118 y=100 width=8 height=19 xoffset=-1 yoffset=5 xadvance=7 page=0 chnl=15
char id=126 x=81 y=13 width=12 height=6 xoffset=-1 yoffset=11 xadvance=11 page=0 chnl=15
char id=198 x=0 y=0 width=22 height=17 xoffset=-1 yoffset=5 xadvance=20 page=0 chnl=15

]],
		FontMap = "rbxassetid://107806549563116", 
		DisplaySize = 29, 
	},
}

return fonts
