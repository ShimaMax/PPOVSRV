
		.mmregs
			
		.def _c_int00
		.text
		
_c_int00:
;çàäàíèå íà÷àëüíûõ çíà÷åíèé äëÿ ðàññ÷åòà ñèíóñîèäû è êîñèíóñîèäû
step    .word 0	
N 		.set 272 
Sk 		.set 0
Ck		.set 32767
S1		.set 1513 ; sin(360 / N)*32768
C1      .set 32733
k		.set 17

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;1-àÿ ëàáà(ðèñîâàíèå 3-åõ ñèíóñîèä, â êà÷åñòâå âõîäíîãî ñèãíàëà);;;;;;;;;;;;;;;

		SSBX OVM

;çàãðóçêà íà÷ çíà÷åíèé â âñïîìîãàòåëüíûå ðåãèñòðû
		xor     A,A
		xor     B,B	
		st     	#Sk,AR1
		st      #Ck,AR2
		st      #S1,AR3
		st      #C1,AR4
		st      #N-1,AR6
		st      #N,BK
		st      #0,AR7		
		stm		#sinus, AR5		
		st		#k-1, BRC	
		rptb	search_Sk_Ck
search_Sn_Cn:		
						
		ld      AR1,A	
		stl 	A, T 	
		mpy 	AR4, A	
		
		ld      AR2,B	
		stl 	B, T 	
		mpy 	AR3, B	
		
		add     B,A		
		sftA    A,-15	
		ld      AR1,B	
		stl     A,AR1	
					
		ld 		AR2,A	
		stl 	A, T 
		mpy 	AR4, A	
		
		stl 	B, T 
		mpy 	AR3,B 
		
		sub     B,A		
		sftA    A,-15
		stl     A,AR2	
search_Sk_Ck: 
		nop
		nop
		banz    block,*AR7- 
		ld      AR1,A		
		stl		A,AR3
		ld      AR2,A
		stl     A,AR4
		st      #Sk,AR1    
		st      #Ck,AR2
		ld      #Ck,A		
block:		
		nop
		nop
		ld      AR1,A
		stl     A,*AR5+		
   		banz    search_Sn_Cn,*AR6-
   		
   		
;;;;;;;;;;;;;;;;;;?eniaaiea neioniea n ?anoioie 2f e 3f io i?aauaouae;;;;;;;;;;;;;;;;;;;;;;;;
   		

   		
   		stm     #sinus, AR2
   		st      #2, AR0
		rpt     #N-1
		mvdd	*AR2+0%, *AR5+ 
				
		stm     #sinus, AR2
   		st      #3, AR0
		rpt     #N-1
		mvdd	*AR2+0%, *AR5+  

		nop	
		nop
		nop
	
		;;;;;;;;;;;;;;;;;;;;;;;;;ÔÈËÜÒÐ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		xor B,B			
		stm     #2,AR7 ; 3 êàñêàäà

main_loop:		
		
		stm		#sinus-2, AR5	;ðåçóëüòàò X
		rpt     #1
		st      #0, *AR5+
		stm 	#filter-2, AR4	;y[i]
		rpt    	#1
		st      #0, *AR4+	
		stm		#sinus-2, AR5	;ðåçóëüòàò Xv
		stm 	#filter-2, AR4	;y[i]
					
		stm 	#N*3-1, brc
	
		rptb IIR
		
 		RSBX OVA ; ñáðîñ áèòà ïåðåïîëíåíèÿ
		
		stm     	#koef, AR3
		stlm        B,AR0
		nop
		nop
		ld          *AR3+0,A
		
		st          #2,AR0
		
		xor  		A,A
						
		rpt #2
		mac *AR5+,*AR3+,A,A ;x[i-6:i]
		rpt #1
		mas *AR4+, *AR3+,A,A ;y[i-6:i]		
		SFTA A,1
		stl  A,-16, *AR4+     ;y[i]
		ld  *AR4-0,A
		ld  *AR5-0,A	
IIR:
		nop
		xor		B,B
		ld      AR7,A
		sub     #1,A
		bc      go,aeq
		add     #5,B
		b       go_2
go:     
		add     #10,B
go_2:
		stl     B,step
		stm		#sinus, AR5	;ðåçóëüòàò X	
		stm 	#filter, AR4	;y[i]
		rpt    	#N*3-1	
		mvdd    *AR4+,*AR5+	
		banz    main_loop,*AR7-
		nop	
		nop
		nop
		
		;;;;;;;;;;;;;;;À×Õ;;;;;;;;;;;;;;;;;;;
		xor     A,A
		stm 	#filter+N, AR4	;y[i]
		stm 	#output, AR2	;y[i] 
		st      #N,AR0
		st      #k,AR7
AFC:
		st 	    #N-1, brc
		rptb 	AFC_point
		mpy 	*AR4+,*AR4,B
		add     B,-15,A	
AFC_point:	
		nop	
		stl     A,-6,T
		mpy 	#273,A
		sfta    A,-8
		
		st      #0,*AR4	  ;Ïåðâîå ïðèáëèæåíèå êîðíÿ èç A	
sqrt_block:			     
		mas 	*AR4,*AR4,A,B  	
		bc      sqrt_find,bleq
		addm    #1,*AR4
		b       sqrt_block
sqrt_find:
		nop	
		
		mpy 	#181, A	
		stl     A,*AR2+
		
		ld		*AR4+0,A
		xor     A,A     
		banz    AFC,*AR7-
		nop
		
			
		.data
		.align	2048
sinus 	.space (N*3+2)*16         ;âûäåëåíèå ïàìÿòè ïîä ñèíóñîèäó/êîñèíóñîèäó
filter  .space N*3*16		  	;ïîä ôèëüòð
output  .space 60*16 
koef	
		.include  	koef.asm