# Reference for Copy/Paste

[resources/tobeorganized.md](To Be Organized)


### Design Patterns
## Creational
Creational patterns are ones that create objects, rather than having to instantiate objects directly. This gives the program more flexibility in deciding which objects need to be created for a given case.

### Abstract factory 
Groups object factories that have a common theme.

### Builder 
Constructs complex objects by separating construction and representation.

### Factory 
Creates objects without specifying the exact class to create.

### Prototype 
Creates objects by cloning an existing object.

### Singleton 
Restricts object creation for a class to only one instance.

---
Source: Wikipedia

---
## C# Cheat Sheet

### Intialize Array
```csharp
string[] words = new string[]
{
                // index from start    index from end
    "The",      // 0                   ^9
    "quick",    // 1                   ^8
    "brown",    // 2                   ^7
    "fox",      // 3                   ^6
    "jumps",    // 4                   ^5
    "over",     // 5                   ^4
    "the",      // 6                   ^3
    "lazy",     // 7                   ^2
    "dog"       // 8                   ^1
};              // 9 (or words.Length) ^0
```
[arrays][def]

[def]: https://learn.microsoft.com/en-us/dotnet/csharp/tutorials/ranges-indexes
---

### Nullable reference types
```csharp
namespace NullableIntroduction
{
    public enum QuestionType
    {
        YesNo,
        Number,
        Text
    }

    public class SurveyQuestion
    {
        public string QuestionText { get; }
        public QuestionType TypeOfQuestion { get; }
    }
}
```
[nullable reference types][def2]

[def2]: https://learn.microsoft.com/en-us/dotnet/csharp/tutorials/nullable-reference-types

---
### String Interpolation
```csharp
var item = (Name: "eggplant", Price: 1.99m, perPackage: 3);
var date = DateTime.Now;
Console.WriteLine($"On {date}, the price of {item.Name} was {item.Price} per {item.perPackage} items.");
```
[string interpolation interactive][def3]



[def3]: https://learn.microsoft.com/en-us/dotnet/csharp/tutorials/exploration/interpolated-strings?tutorial-step=2

### How to use a ternary conditional operator ?: in an interpolation expression
```csharp
var rand = new Random();
for (int i = 0; i < 7; i++)
{
    Console.WriteLine($"Coin flip: {(rand.NextDouble() < 0.5 ? "heads" : "tails")}");
}
```
---
## LINQ
*As stated previously, the query variable itself only stores the query commands. The actual execution of the query is deferred until you iterate over the query variable in a foreach statement.*
```csharp
class IntroToLINQ
{
    static void Main()
    {
        // The Three Parts of a LINQ Query:
        // 1. Data source.
        int[] numbers = new int[7] { 0, 1, 2, 3, 4, 5, 6 };

        // 2. Query creation.
        // numQuery is an IEnumerable<int>
        // Query Syntax
        var numQuery =
            from num in numbers
            where (num % 2) == 0
            select num;

        // 3. Query execution.
        foreach (int num in numQuery)
        {
            Console.Write("{0,1} ", num);
        }

        //Some query operations must be expressed as a method call. The most common such methods are those that return singleton 
        // numeric values, such as Sum, Max, Min, Average, and so on. 
        //These methods must always be called **last** in any query because they represent only a single value and cannot serve as the source for an additional query operation.
        List<int> numbers1 = new() { 5, 4, 1, 3, 9, 8, 6, 7, 2, 0 };
        List<int> numbers2 = new() { 15, 14, 11, 13, 19, 18, 16, 17, 12, 10 };

        // Query #4. 
        // Method Syntax
        double average = numbers1.Average();

        // Query #5.
        IEnumerable<int> concatenationQuery = numbers1.Concat(numbers2);
    }
}
```
[LINQ][def4]

[def4]: https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/introduction-to-linq-queries
---
### Forcing Immediate Execution
*To force immediate execution of any query and cache its results, you can call the ToList or ToArray methods.*
```csharp
List<int> numQuery2 =
    (from num in numbers
     where (num % 2) == 0
     select num).ToList();

// or like this:
// numQuery3 is still an int[]

var numQuery3 =
    (from num in numbers
     where (num % 2) == 0
     select num).ToArray();
```
---
### LINQ experiments
```csharp
// Program.cs
// The Main() method

static IEnumerable<string> Suits()
{
    yield return "clubs";
    yield return "diamonds";
    yield return "hearts";
    yield return "spades";
}

static IEnumerable<string> Ranks()
{
    yield return "two";
    yield return "three";
    yield return "four";
    yield return "five";
    yield return "six";
    yield return "seven";
    yield return "eight";
    yield return "nine";
    yield return "ten";
    yield return "jack";
    yield return "queen";
    yield return "king";
    yield return "ace";
}

// Program.cs
static void Main(string[] args)
{
    var startingDeck = from s in Suits()
                       from r in Ranks()
                       select new { Suit = s, Rank = r };

    // Display each card that we've generated and placed in startingDeck in the console
    foreach (var card in startingDeck)
    {
        Console.WriteLine(card);
    }
}

// Program.cs
public static void Main(string[] args)
{
    var startingDeck = from s in Suits()
                       from r in Ranks()
                       select new { Suit = s, Rank = r };

    foreach (var c in startingDeck)
    {
        Console.WriteLine(c);
    }

    // 52 cards in a deck, so 52 / 2 = 26
    var top = startingDeck.Take(26);
    var bottom = startingDeck.Skip(26);
}


```


[working with LINQ](https://learn.microsoft.com/en-us/dotnet/csharp/tutorials/working-with-linq)
