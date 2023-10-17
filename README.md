# L
**L** is a postfix-oriented programming language that offers basic operations, such as arithmetic operations and logical operations, and other extra operations, like “tell me a joke”. The language uses some constructs similar to assembly languages. There are also unique constructs.
## Authors
 - [Ahmed Ba Matraf](https://github.com/AhmedBamatraf)
 - [Ziyad Salem Boshima](https://github.com/ZiyadBoshima)
 - Syed Abdulrahim
## Usage
### Setup
To use L, begin your code with “start:” and end it with “end start”. The body of the program will be between two curly braces, like so:
```
start:
{
  program_body
}
end start
```
### Variable Definition
To define a variable, use `[mov]` operator likeso:
<pre>
  <em>Variable  Value</em>  [mov]
</pre>
or
<pre>
  <em>Variable  Variable</em>  [mov]
</pre>

The variable type does not need to be declared as L is dynamically type. The possible types of values are: integers, floats, strings.
### Operations
For arithmetic, logical, and relational expressions, the operators are defined as follows: [and], [or], [not], [add], [sub], [mul], [div], [mod], < as [s], > as [b], <= as [se], >= as [be]. These can be used in this syntax:
<pre>
  <em>Variable Variable</em> [operator]
</pre>
or
<pre>
  <em>Value Value</em> [operator]
</pre>
### Print
In order to print results in the console, L provides the `show{}` function, and can be used likeso:
<pre>
  show{<em>Something</em>}
</pre>
Spaces and new lines can be added to the output by using `.` and `.n` respectively. In order to be used with operations and values, a separator symbole `|` must be used. 
<pre>
  show{. | <em>String</em>} // adds space to a single space
  show{<em>String</em> | .n} // adds new line after string
</pre>
The order of the objects inside the can be in any order, and can be repeated as many times.
<pre>
  show{ space_or_newline | value_or_variable_or_operation}
</pre>
### Cast
L provides a casting function, `convert()`, that turns an integer into a string.
<pre>
  convert(<em>variable_or_value</em>)
</pre>
### Tell me a joke
If at times programming feels mundane&mdash;<em>hopefully never with the L language</em>&mdash;run this function:
```
[tell me a joke]
```
