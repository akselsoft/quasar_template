*-------------------------------------------------------------------
* Created by Marco Plaza vfp2nofox@gmail.com / @vfp2Nofox
* ver 2.000 - 26/03/2016
* ver 2.090 - 22/07/2016 :
*	improved error management
*	nfjsonread will return .null. for invalid json
*-------------------------------------------------------------------
Lparameters cjsonstr,isFileName,reviveCollection

#Define crlf Chr(13)+Chr(10)

Private All

stackLevels=Astackinfo(aerrs)

If m.stackLevels > 1
	calledFrom = 'called From '+aerrs(m.stackLevels-1,4)+' line '+Transform(aerrs(m.stackLevels-1,5))
Else
	calledFrom = ''
Endif

oJson = nfJsonCreate2(cjsonstr,isFileName,reviveCollection)

Return Iif(Vartype(m.oJson)='O',m.oJson,.Null.)


*-------------------------------------------------------------------------
Function nfJsonCreate2(cjsonstr,isFileName,reviveCollection)
*-------------------------------------------------------------------------
* validate parameters:

Do Case
Case ;
		Vartype(m.cjsonstr) # 'C' Or;
		Vartype(m.reviveCollection) # 'L' Or ;
		Vartype(m.isFileName) # 'L'

	jERROR('invalid parameter type')

Case  m.isFileName And !File(m.cjsonstr)

	jERROR('File "'+Rtrim(Left(m.cjsonstr,255))+'" does not exist')


Endcase

* process json:

If m.isFileName
	cjsonstr = Filetostr(m.cjsonstr)
Endif


cJson = Rtrim(Chrtran(m.cjsonstr,Chr(13)+Chr(9)+Chr(10),''))
pChar = Left(Ltrim(m.cJson),1)


nl = Alines(aj,m.cJson,20,'{','}','"',',',':','[',']')

For xx = 1 To Alen(aj)
	If Left(Ltrim(aj(m.xx)),1) $ '{}",:[]'  Or Left(Ltrim(m.aj(m.xx)),4) $ 'true/false/null'
		aj(m.xx) = Ltrim(aj(m.xx))
	Endif
Endfor


Try

	x = 1
	cError = ''
	oStack = Createobject('stack')

	oJson = Createobject('empty')

	Do Case
	Case  aj(1)='{'
		x = 1
		oStack.pushObject()
		procstring(m.oJson)

	Case aj(1) = '['
		x = 0
		procstring(m.oJson,.T.)

	Otherwise
		Error 'Invalid Json: expecting [{  received '+m.pChar

	Endcase


	If m.reviveCollection
		oJson = reviveCollection(m.oJson)
	Endif


Catch To oerr

	strp = ''

	For Y = 1 To m.x
		strp = m.strp+aj(m.y)
	Endfor

	Do Case
	Case oerr.ErrorNo = 1098

		cError = ' Invalid Json: '+ m.oerr.Message+crlf+' Parsing: '+Right(m.strp,80)

*+' program line: '+Transform(oerr.Lineno)+' array item '+Transform(m.x)

	Case oerr.ErrorNo = 2034

		cError = ' INVALID DATE: '+crlf+' Parsing: '+Right(m.strp,80)


	Otherwise

		cError = 'program error # '+Transform(m.oerr.ErrorNo)+crlf+m.oerr.Message+' at: '+Transform(oerr.Lineno)+crlf+' Parsing ('+Transform(m.x)+') '

	Endcase

Endtry

If !Empty(m.cError)
	jERROR(m.cError)
Endif

Return m.oJson



*------------------------------------------------
Procedure jERROR( cMessage )
*------------------------------------------------
Error 'nfJson ('+m.calledFrom+'):'+crlf+m.cMessage
Return To nfJsonRead



*--------------------------------------------------------------------------------
Procedure procstring(obj,eValue)
*--------------------------------------------------------------------------------
#Define cvalid 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_'
#Define creem  '_______________________________________________________________'

Private rowpos,colpos,bidim,ncols,arrayName,expecting,arrayLevel,vari
Private expectingPropertyName,expectingValue,objectOpen

expectingPropertyName = !m.eValue
expectingValue = m.eValue
expecting = Iif(expectingPropertyName,'"}','')
objectOpen = .T.
bidim = .F.
colpos = 0
rowpos = 0
arrayLevel = 0
arrayName = ''
vari = ''
ncols = 0

Do While m.objectOpen

	x = m.x+1

	Do Case

	Case m.x > m.nl

		m.x = m.nl

		If oStack.Count > 0
			Error 'expecting '+m.expecting
		Endif

		Return

	Case aj(m.x) = '}' And '}' $ m.expecting
		closeObject()

	Case aj(x) = ']' And ']' $ m.expecting
		closeArray()

	Case  m.expecting = ':'
		If aj(m.x) = ':'
			expecting = ''
			Loop
		Else
			Error 'expecting : received '+aj(m.x)
		Endif

	Case ',' $ m.expecting

		Do Case
		Case aj(x) = ','
			expecting = Iif( '[' $ m.expecting , '[' , '' )
		Case Not aj(m.x) $ m.expecting
			Error 'expecting '+m.expecting+' received '+aj(m.x)
		Otherwise
			expecting = Strtran(m.expecting,',','')
		Endcase


	Case m.expectingPropertyName

		If aj(m.x) = '"'
			propertyName(m.obj)
		Else
			Error 'expecting "'+m.expecting+' received '+aj(m.x)
		Endif


	Case m.expectingValue

		If m.expecting == '[' And m.aj(m.x) # '['
			Error 'expecting [ received '+aj(m.x)
		Else
			procValue(m.obj)
		Endif


	Endcase


Enddo


*----------------------------------------------------------
Function anuevoel(obj,arrayName,valasig,bidim,colpos,rowpos)
*----------------------------------------------------------


If m.bidim

	colpos = m.colpos+1

	If colpos > m.ncols
		ncols = m.colpos
	Endif

	Dimension obj.&arrayName(m.rowpos,m.ncols)

	obj.&arrayName(m.rowpos,m.colpos) = m.valasig

	If Vartype(m.valasig) = 'O'
		procstring(obj.&arrayName(m.rowpos,m.colpos))
	Endif

Else

	rowpos = m.rowpos+1
	Dimension obj.&arrayName(m.rowpos)

	obj.&arrayName(m.rowpos) = m.valasig

	If Vartype(m.valasig) = 'O'
		procstring(obj.&arrayName(m.rowpos))
	Endif

Endif


*-----------------------------------------
Function unescunicode( Value )
*-----------------------------------------


noc=1

Do While .T.

	posunicode = At('\u',m.value,m.noc)

	If m.posunicode = 0
		Return
	Endif

	If Substr(m.value,m.posunicode-1,1) = '\' And Substr(m.value,m.posunicode-2,1) # '\'
		noc=m.noc+1
		Loop
	Endif

	nunic = Evaluate('0x'+ Substr(m.value,m.posunicode+2,4) )

	If Between(m.nunic,0,255)
		unicodec = Chr(m.nunic)
	Else
		unicodec = '&#'+Transform(m.nunic)+';'
	Endif

	Value = Stuff(m.value,m.posunicode,6,m.unicodec)


Enddo

*-----------------------------------
Function unescapecontrolc( Value )
*-----------------------------------

If At('\', m.value) = 0
	Return
Endif

* unescape special characters:

Private aa,elem,unesc


Declare aa(1)
=Alines(m.aa,m.value,18,'\\','\b','\f','\n','\r','\t','\"','\/')

unesc =''

#Define sustb 'bnrt/"'
#Define sustr Chr(127)+Chr(10)+Chr(13)+Chr(9)+Chr(47)+Chr(34)

For Each elem In m.aa

	If ! m.elem == '\\' And Right(m.elem,2) = '\'
		elem = Left(m.elem,Len(m.elem)-2)+Chrtran(Right(m.elem,1),sustb,sustr)
	Endif

	unesc = m.unesc+m.elem

Endfor

Value = m.unesc

*--------------------------------------------
Procedure propertyName(obj)
*--------------------------------------------

vari=''

Do While ( Right(m.vari,1) # '"'  Or ( Right(m.vari,2) = '\"' And Right(m.vari,3) # '\\"' ) ) And Alen(aj) > m.x
	x=m.x+1
	vari = m.vari+aj(m.x)
Enddo

If Right(m.vari,1) # '"'
	Error ' expecting "  received  '+ Right(Rtrim(m.vari),1)
Endif

vari = Left(m.vari,Len(m.vari)-1)
vari = Iif(Isalpha(m.vari),'','_')+m.vari
vari = Chrtran( vari, Chrtran( vari, cvalid,'' ) , creem )

If vari = 'tabindex'
	vari = '_tabindex'
Endif


expecting = ':'
expectingValue = .T.
expectingPropertyName = .F.


*-------------------------------------------------------------
Procedure procValue(obj)
*-------------------------------------------------------------

Do Case
Case aj(m.x) = '{'

	oStack.pushObject()

	If m.arrayLevel = 0


		AddProperty(obj,m.vari,Createobject('empty'))

		procstring(obj.&vari)
		expectingPropertyName = .T.
		expecting = ',}'
		expectingValue = .F.

	Else


		anuevoel(m.obj,m.arrayName,Createobject('empty'),m.bidim,@colpos,@rowpos)
		expectingPropertyName = .F.
		expecting = ',]'
		expectingValue = .T.

	Endif


Case  aj(x) = '['

	oStack.pushArray()

	Do Case

	Case m.arrayLevel = 0

		arrayName = Evl(m.vari,'array')
		rowpos = 0
		colpos = 0
		bidim = .F.

		Try
			AddProperty(obj,(m.arrayName+'(1)'),.F.)
		Catch
			m.arrayName = m.arrayName+'_vfpSafe_'
			AddProperty(obj,(m.arrayName+'(1)'),.F.)
		Endtry

		obj.&arrayName(1) = ''

	Case m.arrayLevel = 1 And !m.bidim

		rowpos = 1
		colpos = 0
		ncols = 1

		Dime obj.&arrayName(1,2)
		bidim = .T.

	Endcase

	arrayLevel = m.arrayLevel+1

	vari=''

	expecting = Iif(!m.bidim,'[]{',']')
	expectingValue = .T.
	expectingPropertyName = .F.

Otherwise

	isstring = aj(m.x)='"'
	x = m.x + Iif(m.isstring,1,0)

	Value = ''

	Do While .T.

		Value = m.value+m.aj(m.x)

		If m.isstring
			If Right(m.value,1) = '"' And ( Right(m.value,2)  # '\"' Or Right(m.value,3) = '\\' )
				Exit
			Endif
		Else
			If Right(m.value,1) $ '}],'  And ( Left(Right(m.value,2),1) # '\' Or Left(Right(Value,3),2) = '\\')
				Exit
			Endif
		Endif

		If m.x < Alen(aj)
			x = m.x+1
		Else
			Exit
		Endif

	Enddo

	closeChar = Right(m.value,1)

	Value = Rtrim(m.value,1,m.closeChar)

	If Empty(Value) And  Not ( m.isstring And m.closeChar = '"'  )
		Error 'Expecting value received '+m.closeChar
	Endif

	Do Case

	Case  m.isstring
		If m.closeChar # '"'
			Error 'expecting " received '+m.closeChar
		Endif

	Case oStack.isObject() And Not m.closeChar $ ',}'
		Error 'expecting ,} received '+m.closeChar

	Case oStack.isArray() And  Not m.closeChar $ ',]'
		Error 'expecting ,] received '+m.closeChar

	Endcase



	If m.isstring

* don't change this lines sequence!:
		unescunicode(@Value)  && 1
		unescapecontrolc(@Value)  && 2
		Value = Strtran(m.value,'\\','\')  && 3

** check for Json Date:
		If isJsonDt( m.value )
			Value = jsonDateToDT( m.value )
		Endif

	Else

		Value = Alltrim(m.value)

		Do Case
		Case m.value == 'null'
			Value = .Null.
		Case m.value == 'true' Or m.value == 'false'
			Value = Value='true'
		Case Empty(Chrtran(m.value,'-1234567890.E','')) And Occurs('.',m.value) <= 1 And Occurs('-',m.value) <= 1 And Occurs('E',m.value)<=1
			If Not 'E' $ m.value
				Value = Cast( m.value As N( Len(m.value)  , Iif(At('.',m.value)>0,Len(m.value)-At( '.',m.value) ,0) ))
			Endif
		Otherwise
			Error 'expecting "|number|null|true|false|  received '+aj(m.x)
		Endcase


	Endif


	If m.arrayLevel = 0


		AddProperty(obj,m.vari,m.value)

		expecting = '}'
		expectingValue = .F.
		expectingPropertyName = .T.

	Else

		anuevoel(obj,m.arrayName,m.value,m.bidim,@colpos,@rowpos)
		expecting = ']'
		expectingValue = .T.
		expectingPropertyName = .F.

	Endif

	expecting = Iif(m.isstring,',','')+m.expecting


	Do Case
	Case m.closeChar = ']'
		closeArray()
	Case m.closeChar = '}'
		closeObject()
	Endcase

Endcase


*------------------------------
Function closeArray()
*------------------------------

If oStack.Pop() # 'A'
	Error 'unexpected ] '
Endif

If m.arrayLevel = 0
	Error 'unexpected ] '
Endif

arrayLevel = m.arrayLevel-1

If m.arrayLevel = 0

	arrayName = ''
	rowpos = 0
	colpos = 0

	expecting = Iif(oStack.isObject(),',}','')
	expectingPropertyName = .T.
	expectingValue = .F.

Else

	If  m.bidim
		rowpos = m.rowpos+1
		colpos = 0
		expecting = ',]['
	Else
		expecting = ',]'
	Endif

	expectingValue = .T.
	expectingPropertyName = .F.

Endif



*-------------------------------------
Procedure closeObject
*-------------------------------------

If oStack.Pop() # 'O'
	Error 'unexpected }'
Endif

If m.arrayLevel = 0
	expecting = ',}'
	expectingValue = .F.
	expectingPropertyName = .T.
	objectOpen = .F.
Else
	expecting = ',]'
	expectingValue = .T.
	expectingPropertyName = .F.
Endif


*----------------------------------------------
Function reviveCollection( o )
*----------------------------------------------

Private All

oConv = Createobject('empty')

nProp = Amembers(elem,m.o,0,'U')

For x = 1 To m.nProp

	estaVar = m.elem(x)

	esArray = .F.
	esColeccion = Type('m.o.'+m.estaVar) = 'O' And Right( m.estaVar , 14 ) $ '_KV_COLLECTION,_KL_COLLECTION' And Type( 'm.o.'+m.estaVar+'.collectionitems',1) = 'A'

	Do Case
	Case m.esColeccion

		estaProp = Createobject('collection')

		tv = m.o.&estaVar

		m.keyValColl = Right( m.estaVar , 14 ) = '_KV_COLLECTION'

		For T = 1 To Alen(m.tv.collectionItems)

			If m.keyValColl
				esteval = m.tv.collectionItems(m.T).Value
			Else
				esteval = m.tv.collectionItems(m.T)
			Endif

			If Vartype(m.esteval) = 'O' Or Type('esteVal',1) = 'A'
				esteval = reviveCollection(m.esteval)
			Endif

			If m.keyValColl
				estaProp.Add(esteval,m.tv.collectionItems(m.T).Key)
			Else
				estaProp.Add(m.esteval)
			Endif

		Endfor

	Case Type('m.o.'+m.estaVar,1) = 'A'

		esArray = .T.

		For T = 1 To Alen(m.o.&estaVar)

			Dimension &estaVar(m.T)

			If Type('m.o.&estaVar(m.T)') = 'O'
				&estaVar(m.T) = reviveCollection(m.o.&estaVar(m.T))
			Else
				&estaVar(m.T) = m.o.&estaVar(m.T)
			Endif

		Endfor

	Case Type('m.o.'+estaVar) = 'O'
		estaProp = reviveCollection(m.o.&estaVar)

	Otherwise
		estaProp = m.o.&estaVar

	Endcase


	estaVar = Strtran( m.estaVar,'_KV_COLLECTION', '' )
	estaVar = Strtran( m.estaVar, '_KL_COLLECTION', '' )

	Do Case
	Case m.esColeccion
		AddProperty(m.oConv,m.estaVar,m.estaProp)
	Case  m.esArray
		AddProperty(m.oConv,m.estaVar+'(1)')
		Acopy(&estaVar,m.oConv.&estaVar)
	Otherwise
		AddProperty(m.oConv,m.estaVar,m.estaProp)
	Endcase

Endfor

Try
	retCollection = m.oConv.Collection.BaseClass = 'Collection'
Catch
	retCollection = .F.
Endtry

If m.retCollection
	Return m.oConv.Collection
Else
	Return m.oConv
Endif


*----------------------------------
Function isJsonDt( cstr )
*----------------------------------
Return Iif( Len(m.cstr) = 19 ;
	AND Len(Chrtran(m.cstr,'01234567890:T-','')) = 0 ;
	and Substr(m.cstr,5,1) = '-' ;
	and Substr(m.cstr,8,1) = '-' ;
	and Substr(m.cstr,11,1) = 'T' ;
	and Substr(m.cstr,14,1) = ':' ;
	and Substr(m.cstr,17,1) = ':' ;
	and Occurs('T',m.cstr) = 1 ;
	and Occurs('-',m.cstr) = 2 ;
	and Occurs(':',m.cstr) = 2 ,.T.,.F. )


*-----------------------------------
Procedure jsonDateToDT( cJsonDate )
*-----------------------------------
Return Eval("{^"+m.cJsonDate+"}")



******************************************
Define Class Stack As Collection
******************************************

*---------------------------
	Function pushObject()
*---------------------------
	This.Add('O')

*---------------------------
	Function pushArray()
*---------------------------
	This.Add('A')

*--------------------------------------
	Function isObject()
*--------------------------------------
	If This.Count > 0
		Return This.Item( This.Count ) = 'O'
	Else
		Return .F.
	Endif


*--------------------------------------
	Function isArray()
*--------------------------------------
	If This.Count > 0
		Return This.Item( This.Count ) = 'A'
	Else
		Return .F.
	Endif

*----------------------------
	Function Pop()
*----------------------------
	cret = This.Item( This.Count )
	This.Remove( This.Count )
	Return m.cret

******************************************
Enddefine
******************************************


