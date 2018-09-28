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

#ifdef __HARBOUR__
    #include 'hbclass.ch'
#else
    #include 'protheus.ch'
#endif

#include 'fileio.ch'

#define CR Chr( 13 )
#define FF Chr( 12 )
#define LF Chr( 10 )
#define HT Chr( 9 )
#define BS Chr( 8 )
#define KEY   1
#define VALUE 2

#xcommand WRITE <*cExpr*> => FWrite( M->NBUFFER, <cExpr> )

/**
 * A JSON object is a hashmap with support for serialization of its members
 */
Class NGJsonObject From NGHashMap
    Method New() Constructor
    Method Serialize()
EndClass

/**
 * Creates a JSON object. May receive an array of key-value pairs with the
 * initial items to be stored
 *
 * @param aValues {Array} - initial items
 * @param nSize {Number} - values to allocate when you known how many items you
 * have
 */
Method New( aValues, nSize ) Class NGJsonObject
    Local nIndex
    _Super:New( IIf( nSize == Nil, 256, nSize ) )

    If ValType( aValues ) == 'A' .And. !Empty( aValues )
        For nIndex := 1 To Len( aValues )
            ::Put( aValues[ nIndex, KEY ], aValues[ nIndex, VALUE ] )
        Next
    EndIf
Return Self

/**
 * Serializes the JSON object
 *
 * @author Marcelo Camargo
 * @returns the JSON string
 */
Method Serialize() Class NGJsonObject
    Local cJson := ''
    Local nSize
    Local cFile

    Private NBUFFER
    Private NINDENT     := 0
    Private NJSONINDENT := 4

    cFile := NextTemp()
    MakeDir( '\tmp' )
    Do While File( cFile )
        cFile := NextTemp()
    EndDo

    M->NBUFFER := FCreate( cFile )
    AsObject( Self )
    WRITE CRLF
    nSize := FSeek( M->NBUFFER, 0, FS_RELATIVE )
    FSeek( M->NBUFFER, 0 )
    FRead( M->NBUFFER, cJson, nSize )
    FClose( M->NBUFFER )
    FErase( cFile )
Return cJson

/**
 * Provides a filename to be used as temporary file
 *
 * @author Marcelo Camargo
 * @returns the path for a temporary unused file
 */
Static Function NextTemp()
    Local nIndex
    Local cName   := '\tmp\'
    Local cLength := Randomize( 10, 20 )

    For nIndex := 1 To cLength
        cName += Chr( Randomize( 65, 90 ) )
    Next

    cName += '.json'
Return cName

/**
 * JSON representation of an object
 *
 * @author Marcelo Camargo
 * @param oObject {Object}
 */
Static Function AsObject( oObject )
    Local aKeys
    Local nIndex
    Local nLength
    Local xValue
    Local aPairs := {}
    Local cIndent

    Private M->NINDENT := M->NINDENT + 1

    If GetClassName( oObject ) == 'NGJSONOBJECT'
        aKeys := aSort( oObject:Keys() )
        For nIndex := 1 To Len( aKeys )
            xValue := oObject:Get( aKeys[ nIndex ] )
            If ValType( xValue ) $ 'ACDLNOU'
                aAdd( aPairs, { aKeys[ nIndex ], xValue } )
            EndIf
        Next
    Else
        aKeys := ClassDataArr( oObject, .T. )
        For nIndex := 1 To Len( aKeys )
            xValue := aKeys[ nIndex, VALUE ]
            If ValType( xValue ) $ 'ACDLNOU'
                aAdd( aPairs, { aKeys[ nIndex, KEY ], xValue } )
            EndIf
        Next
    EndIf

    aKeys   := Nil
    nLength := Len( aPairs )

    Begin Sequence
        WRITE '{'

        If nLength == 0
            Break
        EndIf

        WRITE CRLF
        cIndent := Space( M->NINDENT * M->NJSONINDENT )
        For nIndex := 1 To nLength
            WRITE cIndent + AsString( aPairs[ nIndex, KEY ] ) + ': '
            AsValue( aPairs[ nIndex, VALUE ] )
            WRITE ',' + CRLF
            // Release memory for each item
            aPairs[ nIndex ] := Nil
        Next
        aPairs := Nil

        // Remove trailing comma + CRLF
        If nLength > 0
            FSeek( M->NBUFFER, -3, FS_RELATIVE )
            WRITE CRLF
        EndIf

        WRITE Space( (M->NINDENT - 1) * M->NJSONINDENT )
    End Sequence

    WRITE '}'
Return

/**
 * JSON representation of a unknown or literal value
 *
 * @author Marcelo Camargo
 * @param xValue {Mixed}
 */
Static Function AsValue( xValue )
    Local cType := ValType( xValue )

    Do Case
        Case cType == 'C'
            WRITE AsString( xValue )
        Case cType == 'U'
            WRITE 'null'
        Case cType == 'L'
            WRITE IIf( xValue, 'true', 'false' )
        Case cType == 'N'
            WRITE cValToChar( xValue )
        Case cType == 'A'
            AsArray( xValue )
        Case cType == 'D'
            WRITE '"' + FWTimeStamp( 3, xValue, '00:00:00' ) + '"'
        Case cType == 'O'
            AsObject( xValue )
    EndCase
Return

/**
 * JSON representation of an array of values
 *
 * @author Marcelo Camargo
 * @param aArray {Array}
 */
Static Function AsArray( aArray )
    Local nLength
    Local nIndex
    Local cIndent

    nLength := Len( aArray )
    WRITE '['

    Begin Sequence
        If nLength == 0
            Break
        EndIf

        WRITE CRLF
        cIndent := Space( (M->NINDENT + 1) * M->NJSONINDENT )
        For nIndex := 1 To nLength
            WRITE cIndent
            AsValue( aArray[ nIndex ] )
            WRITE ',' + CRLF
        Next

        // Remove trailing comma + CRLF
        If nLength > 0
            FSeek( M->NBUFFER, -3, FS_RELATIVE )
            WRITE CRLF
        EndIf

        WRITE Space( M->NINDENT * M->NJSONINDENT )
    End Sequence

    WRITE ']'
Return

/**
 * String escape according to JSON specification
 *
 * @author Marcelo Camargo
 * @param cStr {String}
 * @returns the escaped string
 */
Static Function AsString( cStr )
    cStr := StrTran( cStr, '\', '\\' )
    cStr := StrTran( cStr, '"', '\"' )
    cStr := StrTran( cStr, BS, '\b' )
    cStr := StrTran( cStr, CR, '\r' )
    cStr := StrTran( cStr, FF, '\f')
    cStr := StrTran( cStr, HT, '\t' )
    cStr := StrTran( cStr, LF, '\n' )
    cStr := '"' + cStr + '"'
Return cStr
