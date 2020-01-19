Offical repository for Avian, the first Actor-Oriented Programming Language. First, let's start with a description of the Actor-Oriented Programming paradigm itself (note this syntax isn't final as Avian is early in development):

# Actor-Oriented Programming
What is Actor-Oriented Programming (AOP)? AOP is a new paradigm branching off from Object-Oriented Programming (OOP). AOP takes the focus away from the data and moves it back to the implementation. How is this achieved? Imagine a namespace had a baby with an interface, and you've got actors. Actors are the main focus of AOP.

The Pillars of Actor-Oriented Programming are:
1. Explicitness over implicitness
2. Data cannot "act". Data must rely on actors to act for them.
3. Inheritance
4. Polymorphism

"Wait," you might say, "two of those are from the three pillars of OOP!" and you'd be right. AOP is a paradigm based heavily on OOP, just taking away all of the power from data to act since they've been too naughty for too long with that privilege. Data should NOT act, it should ask for actors to act on it.

## Actors
This is the main focus of Actor-Oriented Programming, quite obviously. Actors are essentially both a namespace and an interface from OOP. Actors can have both procedures and actions. What's the diffference between the two? First, let's explain the concept of object precedence in parameters.

### Object Precedence
When an object has precedence, that essentially means it's more important in the procedure/action then another parameter. Object precedence is an important concept in AOP. Let's take a car, for example, using Avian:
```
Car :: obj {
    tires: [4]Tire,
}

Tire :: obj {
    ...
}

ACar :: actor (tires: []Tire) {
    add_tire :: act (tire: Tire, i: int) (
        'tires[i] = tire;
    }
}

main :: proc() {
    car  := Car[ACar('tires)]{};
    tire := Tire{};
    car->add_tire(tire, 0);
}
```
In this example, the car has higher object precedence than the tire, thus the car is the one employing the actor, instead of vice versa. This example also illustrates the point that objects can't act by themselves. The car first has to manually employ the `ACar` actor in its initialization. This is all up to the programmers using the object, and can be used to remove functionality you're never going to use, new functionality, or even choosing from different types of functionality!

### Procedures
Procedures should not have side-effects. Obviously, there are edge cases to this, but for the most part, there shouldn't be unintended side-effects. If your procedure requires a side-effect, make sure to document it well. Other than that, procedures are just normal functions. All parameters have equal precedence in the procedure.

### Actions
Actions should always have side-effects and have lopsided object precedence. However, actions should only have side-effects on the object that's employing that actor. If there's a reason as to why your action has a side-effect on another parameter, either that parameter should have higher precedence and be the one calling the action or there's most likely something wrong with your code structure. If there's a reason both of those are false, be sure to document it well.

### Employing Actors
This is one of the major features of AOP. Actors handle the implementation, all the programmer has to do do is tell the actor "Hey, use this data please." Example:
```
Foo :: obj {
    list: []?T;
}

BubbleSorter :: actor (list: []?T) {
    sort :: act () {
        ...
    }
}

QuickSorter :: actor (list: []?T) {
    sort :: act () {
        ...
    }
}

main :: proc () {
    bubble_foo := Foo(int)[BubbleSorter('list)]{};
    quick_foo  := Foo(int)[QuickSorter('list)]{};
    
    // Fill bubble_foo with data...
    // Fill quick_foo with data...
    
    bubble_foo->sort();
    quick_foo->sort();
}
```
This example displays both generics AND choosing different functionality by employing different actors! You're able to use different functionality by employing separate actors, allowing the programmer to decide specific implementations instead of the object itself! The previous example of employment is very similar to OOP's clunky workaround way of having an abstract object as a member in it, then calling functions through that member, though this is much more elegant and much more flexible (as in OOP this can't be achieved without accounting for it in the class, which removes power from the programmer and locks the implementation away).

## Conclusion on Actor-Oriented Programming
Though there is a lot more to AOP, this is the most the subject will be talked about in here. A more comprehensive explanation on AOP will be developed in the future. It's simply too much information to pack into Avian's README. In essense, AOP brings the focus back to the implementation and gives full power to the programmer instead of the data. Data objects should NOT dictate how the data is used, they're simply containers. The programmer should dictate that.

# Avian
TODO: Fill this out