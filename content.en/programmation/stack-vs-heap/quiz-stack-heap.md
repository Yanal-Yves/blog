---
title: "Quiz: Stack and Heap"
description: "Interactive quiz to test your knowledge of the Stack and the Heap in C#: memory allocation, value types and reference types."
draft: false
---

## 📝 Test your knowledge

Have you really grasped the nuance? This is the moment of truth. Click "See the answer" to check your understanding.

### Question 1
**What is the main characteristic of the Stack compared to the Heap in terms of performance?**

* A) It is slower but can store more data.
* B) It is much faster to access and allocate.
* C) There is no performance difference.
* D) It is optimized for large objects only.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: It is much faster.</strong><br>
Allocation on the Stack is immediate (moving a CPU pointer), whereas the Heap requires finding a free space and managing it later via the Garbage Collector.
</blockquote>
</details>

---

### Question 2
**In C#, where is the value of a local variable of type `int` stored (for example `int age = 25;`)?**

* A) On the Heap.
* B) In the processor's registers only.
* C) On the Stack.
* D) Part on the Stack and part on the Heap.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: On the Stack.</strong><br>
It is a value type. It lives directly in the method's execution frame on the Stack. It does not need the giant warehouse in order to exist.
</blockquote>
</details>

---

### Question 3
**When you instantiate a class (e.g. `var user = new User();`), what does the variable `user` located on the Stack contain?**

* A) The entire object with all its data.
* B) A copy of the object.
* C) Nothing, the variable is empty until you use it.
* D) The memory address (reference) pointing to the object in the Heap.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer D: The memory address (reference).</strong><br>
The variable on the Stack acts like a "pointer" or a remote control. The actual object (the data) is stored in the Heap.
</blockquote>
</details>

---

### Question 4
**If you declare `int? score = null;`, where is this variable stored?**

* A) Only on the Heap because it is null.
* B) Only on the Stack.
* C) It is not stored in memory because it does not exist.
* D) It is an empty reference pointing to the Heap.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: Only on the Stack.</strong><br>
This is the classic pitfall! A `Nullable<int>` remains a struct (value type). It takes up space on the Stack to store a boolean (HasValue=false) and the default value.
</blockquote>
</details>

---

### Question 5
**Who is responsible for cleaning up memory in the Heap in C#?**

* A) The operating system at the end of the program.
* B) The developer, manually.
* C) The method, as soon as it finishes.
* D) The Garbage Collector.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer D: The Garbage Collector.</strong><br>
It is an automatic process that runs regularly to identify and free the memory of Heap objects that are no longer referenced by anyone.
</blockquote>
</details>

---

### Question 6
**What happens if you copy a variable of a class type (`User u2 = u1;`) and then modify `u2`?**

* A) It also modifies the object pointed to by `u1`.
* B) It does not modify `u1` because an independent copy was created.
* C) It causes a compilation error.
* D) The original object is deleted and replaced.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer A: It also modifies `u1`.</strong><br>
Since you copied the address (the reference), both variables point to EXACTLY the same object in memory. If you change the wallpaper of the house via address 1, it also changes for whoever holds address 2.
</blockquote>
</details>

---

### Question 7
**What is a `StackOverflowException`?**

* A) When the Heap is full because of objects that are too large.
* B) When you try to access a null variable.
* C) When the Stack is saturated, often by infinite recursive method calls.
* D) When the Garbage Collector can no longer run.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: Saturation of the Stack.</strong><br>
The Stack's space is limited. If you push too many method calls without ever popping them (infinite recursion), it overflows.
</blockquote>
</details>

---

### Question 8
**Which statement is true about `string?` (Nullable Reference Type) in recent C#?**

* A) It adds a boolean in memory to indicate whether the string is null.
* B) It moves the string onto the Stack.
* C) It is purely a hint for the compiler; in memory it is identical to `string`.
* D) It allows the string to be stored without using the Garbage Collector.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer C: It is a compiler aid.</strong><br>
In memory, it is still just a reference (address). The `?` only serves to warn the developer at compile time that null values must be checked, but it does not change the binary structure.
</blockquote>
</details>

---

### Question 9
**Why do we sometimes prefer to use a `struct` rather than a `class` for small data objects?**

* A) To benefit from inheritance.
* B) To avoid pressure on the Garbage Collector by staying on the Stack.
* C) To be able to set them to null easily.
* D) Because structs have an unlimited size.

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer B: Avoiding pressure on the GC.</strong><br>
If the struct is used as a local variable, it is allocated/deallocated instantly on the Stack ("for free"). This avoids giving work to the Garbage Collector in the Heap.
</blockquote>
</details>

---

### Question 10
**In the case `User u = null;`, what does the variable `u` physically contain on the Stack?**

* A) Absolutely nothing (empty).
* B) A hidden empty object.
* C) An exception.
* D) A special address (usually all bits set to 0).

<details>
<summary>🔻 See the answer</summary>
<blockquote>
<strong>Answer D: A special address (0x000000).</strong><br>
In computing, "nothing" does not exist. The null reference is concretely an address equal to zero, meaning "I point nowhere".
</blockquote>
</details>
