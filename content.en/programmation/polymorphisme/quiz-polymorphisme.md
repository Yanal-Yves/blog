---
title: "Quiz: Polymorphism"
description: "Interactive quiz on polymorphism in C#: test your understanding of Vtables, static/dynamic binding and the virtual, override and new keywords."
draft: false
---

## 📝 Test your knowledge

Have you really grasped the internal mechanics of polymorphism and Vtables? This is the moment to check whether you have mastered the difference between static and dynamic binding. Click "See the answer" to confirm.

### Question 1
**In the code `Animal a = new Dog();`, if you call `a.SayHello()` (a non-virtual method), which version of the method is executed?**

* A) The one from the `Dog` class because the object is a Dog.
* B) The one from the `Animal` class because the variable is of type Animal.
* C) None, it causes a compilation error.
* D) The `Dog`'s one, only if it uses the `override` keyword.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: The one from the `Animal` class.</strong><br>
Since the method is not virtual, the compiler uses static binding. It relies solely on the type of the <strong>variable</strong> (`Animal`) and sets in stone the call to `Animal.SayHello` as early as compile time.
</blockquote>
</details>

---

### Question 2
**Which C# keyword enables dynamic binding (a call via the Vtable) in the base class?**

* A) `static`
* B) `override`
* C) `virtual`
* D) `new`

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: `virtual`.</strong><br>
It is this keyword that signals to the compiler that it must not freeze the method's address, but instead set up a dynamic resolution mechanism (a lookup) for execution.
</blockquote>
</details>

---

### Question 3
**What is a Vtable (Virtual Method Table) concretely?**

* A) An SQL database storing the objects.
* B) An array of pointers to the memory addresses of the methods.
* C) A list of the method's local variables.
* D) A memory space reserved on the Stack.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: An array of pointers.</strong><br>
It is a structure in the class's metadata (the MethodTable) that maps each virtual method to the real memory address of the code to execute.
</blockquote>
</details>

---

### Question 4
**When is the destination address of a "static" (non-virtual) method call determined?**

* A) At the moment the object is instantiated (`new`).
* B) At runtime, just before the call.
* C) At compile time.
* D) When the Garbage Collector runs.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: At compile time.</strong><br>
The compiler knows the type of the variable. It therefore generates a direct jump instruction to the address of the corresponding method, without needing to check what happens in memory.
</blockquote>
</details>

---

### Question 5
**How does the Runtime find the Vtable corresponding to an object at execution time?**

* A) It looks up the class name in an XML file.
* B) It analyzes the original source code.
* C) It consults the TypeHandle located in the object's header on the Heap.
* D) It asks the compiler via an exception.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: Via the object's header (TypeHandle).</strong><br>
Every object on the Heap has an invisible header that points to its "identity card" (the MethodTable), which contains the Vtable. This is how the Runtime knows it is dealing with a `Dog` and not an `Animal`.
</blockquote>
</details>

---

### Question 6
**If the `Cat` class defines `public new void SayHello()`, what happens at the level of the Vtable inherited from `Animal`?**

* A) The address of `Animal.SayHello` is replaced by that of `Cat.SayHello`.
* B) A critical error occurs.
* C) Nothing, the `Cat.SayHello` method is ignored in `Animal`'s slot.
* D) The Vtable is deleted to optimize memory.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: Nothing, the method is ignored in the parent slot.</strong><br>
The `new` keyword (hiding) does not use the Vtable mechanism to override the parent. The address in the Vtable slot remains that of `Animal`. The `Cat.SayHello` method exists "alongside" it but is not accessible through an `Animal` reference.
</blockquote>
</details>

---

### Question 7
**What does the term "Indirection" mean in the context of a virtual call?**

* A) That the code is badly written.
* B) That the processor must take a detour through the Vtable to find the address of the code.
* C) That the method is called recursively.
* D) That the object is stored on the hard drive.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: The detour through the Vtable.</strong><br>
Instead of jumping directly to the code (a direct call), the processor must first read a memory address in an array (the Vtable), then jump to that address. This extra step is the indirection.
</blockquote>
</details>

---

### Question 8
**In the diagram provided, why does the red arrow (static call) bypass the Vtable?**

* A) Because it is a bug in the diagram.
* B) Because the static call is slower.
* C) Because the compiler already hard-wired the `@Addr_A` (Animal) address.
* D) Because the `SayHello` method does not exist on the Dog.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: The address is hard-wired.</strong><br>
The static call completely ignores the real instance and its Vtable. It goes straight to the code defined by the type of the variable.
</blockquote>
</details>

---

### Question 9
**What is the condition for a method's slot in the Vtable to be updated with the address of the child's method?**

* A) The child must use the `override` keyword.
* B) The child must use the `new` keyword.
* C) The method must be `private`.
* D) The child must not have a constructor.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer A: Using `override`.</strong><br>
It is `override` that instructs the system to replace the parent method's address with the child's inside the corresponding slot in the Vtable.
</blockquote>
</details>

---

### Question 10
**Why do we say that the virtual (polymorphic) call is more "flexible"?**

* A) Because it allows you to change the source code without recompiling.
* B) Because it adapts to the actual type of the object at runtime, whatever it is.
* C) Because it uses less memory.
* D) Because it lets you avoid using classes.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: It adapts to the actual type of the object.</strong><br>
No matter that the variable is of type `Animal`, if the object is a `Cat`, it is the `Cat`'s behavior that will be triggered thanks to dynamic resolution.
</blockquote>
</details>
