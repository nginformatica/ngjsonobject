/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2018 NG Informática - TOTVS Software Partner
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include 'protheus.ch'
#include 'testsuite.ch'
#include 'ngjsonobject.ch'

#define CR Chr( 13 )
#define FF Chr( 12 )
#define LF Chr( 10 )
#define HT Chr( 9 )
#define BS Chr( 8 )
#define CRLF Chr( 13 ) + Chr( 10 )

Class NGJsonTest
    Data Eita
    Data Preula
    Method New( cEita, cPreula ) Constructor
EndClass

Method New( cEita, cPreula ) Class NGJsonTest
    ::Eita   := cEita
    ::Preula := cPreula
Return

TestSuite NGJsonObject Description 'NGJsonObject' Verbose
    Data oJson

    Feature _01_New    Description 'It should create a JSON object'
    Feature _02_Empty  Description 'It should serialize an empty JSON'
    Feature _03_String Description 'It should serialize a string value'
    Feature _04_Null   Description 'It should serialize a null value'
    Feature _05_Bool   Description 'It should serialize a boolean value'
    Feature _06_Number Description 'It should serialize a numeric value'
    Feature _07_Array  Description 'It should serialize an array'
    Feature _08_Object Description 'It should serialize an object'
    Feature _09_Skip   Description 'It should skip serialization of unknown values'
    Feature _10_Date   Description 'It should serialize a date using ISO 8601'
    Feature _11_Perf   Description 'It should be able to handle a large JSON'
EndTestSuite

Feature _01_New TestSuite NGJsonObject
    ::oJson := #{}
Return

Feature _02_Empty TestSuite NGJsonObject
    ::Expect( ::oJson:Serialize() ):ToBe( '{}' + CRLF )
Return

Feature _03_String TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "\r\f\n\t\b": "ok",' + CRLF
    cExpect += '    "hel\"o": "WORLD",' + CRLF
    cExpect += '    "hel\\o": "World",' + CRLF
    cExpect += '    "hello": "world"' + CRLF
    cExpect += '}' + CRLF

    oJson := #{}
    oJson[#hello]     := 'world'
    oJson[#('hel"o')] := 'WORLD'
    oJson[#('hel\o')] := 'World'
    oJson[#(CR + FF + LF + HT + BS)] := 'ok'
    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _04_Null TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "hope": null' + CRLF
    cExpect += '}' + CRLF

    oJson := #{}
    oJson[#hope] := Nil

    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _05_Bool TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "alpha": true,' + CRLF
    cExpect += '    "bravo": false' + CRLF
    cExpect += '}' + CRLF

    oJson := #{}
    oJson[#alpha] := .T.
    oJson[#bravo] := .F.

    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _06_Number TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "first": 0.12,' + CRLF
    cExpect += '    "second": 1231323.123,' + CRLF
    cExpect += '    "third": -95' + CRLF
    cExpect += '}' + CRLF

    oJson := #{}
    oJson[#first]  := 0.12
    oJson[#second] := 1231323.123
    oJson[#third]  := -95

    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _07_Array TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "empty": [],' + CRLF
    cExpect += '    "one": [' + CRLF
    cExpect += '        1' + CRLF
    cExpect += '    ],' + CRLF
    cExpect += '    "two": [' + CRLF
    cExpect += '        1,' + CRLF
    cExpect += '        2' + CRLF
    cExpect += '    ]' + CRLF
    cExpect += '}' + CRLF

    oJson := #{ empty := {}, one := { 1 }, two := { 1, 2 } }
    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _08_Object TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "empty": {},' + CRLF
    cExpect += '    "functional": {' + CRLF
    cExpect += '        "haskell": [' + CRLF
    cExpect += '            2' + CRLF
    cExpect += '        ],' + CRLF
    cExpect += '        "scala": [' + CRLF
    cExpect += '            3' + CRLF
    cExpect += '        ]' + CRLF
    cExpect += '    },' + CRLF
    cExpect += '    "imperative": {' + CRLF
    cExpect += '        "basic": [' + CRLF
    cExpect += '            1' + CRLF
    cExpect += '        ]' + CRLF
    cExpect += '    },' + CRLF
    cExpect += '    "logic": {' + CRLF
    cExpect += '        "EITA": "foo",' + CRLF
    cExpect += '        "PREULA": "bar"' + CRLF
    cExpect += '    }' + CRLF
    cExpect += '}' + CRLF

    oJson := #{}

    oJson[#empty] := #{}

    oJson[#imperative] := #{}
    oJson[#imperative][#basic] := { 1 }

    oJson[#functional] := #{}
    oJson[#functional][#haskell] := { 2 }
    oJson[#functional][#scala]   := { 3 }

    oJson[#logic] := NGJsonTest():New( 'foo', 'bar' )

    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _09_Skip TestSuite NGJsonObject
    Local oJson := #{}
    oJson[#foo] := {|| 1}

    ::Expect( oJson:Serialize() ):ToBe( '{}' + CRLF )
Return

Feature _10_Date TestSuite NGJsonObject
    Local oJson
    Local cExpect

    cExpect := '{' + CRLF
    cExpect += '    "date": "1996-12-04T00:00:00"' + CRLF
    cExpect += '}' + CRLF

    oJson := #{ date := SToD( '19961204' ) }

    ::Expect( oJson:Serialize() ):ToBe( cExpect )
Return

Feature _11_Perf TestSuite NGJsonObject
    Local oJson
    Local nHandle
    Local nStart

    dbUseArea( .T., 'CTREECDX', '\system\sx2990.dtc', 'SX2', .T., .T. )
    dbSelectArea( 'SX2' )
    SX2->( dbSetOrder( 1 ) )

    nStart := Seconds()
    ConOut( 'BEGIN PUT NG' )
    oJson := NGJsonObject():New( {}, 10000 )
    Do While !SX2->( EoF() )
        oJson[#(SX2->X2_CHAVE)] := NGJsonObject():New( {}, 5 )
        oJson[#(SX2->X2_CHAVE)][#name]   := EncodeUtf8( SX2->X2_NOME )
        oJson[#(SX2->X2_CHAVE)][#fields] := { Nil }
        SX2->( dbSkip() )
    EndDo
    ConOut( 'END PUT NG', Seconds() - nStart )

    nHandle := FCreate( '\sx2.json' )
    nStart  := Seconds()
    ConOut( 'BEGIN SERIALIZE NG' )
    FWrite( nHandle, oJson:Serialize() )
    ConOut( 'END SERIALIZE NG', Seconds() - nStart )
    FClose( nHandle )
    CpyS2T( '\sx2.json', 'C:\tmp' )
    SX2->( dbCloseArea() )
Return

CompileTestSuite NGJsonObject
