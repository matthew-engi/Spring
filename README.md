# Spring

---

**Author:** Matthew (Creaco)  
**License:** `License.luau`  
**Version:** `1.0.0`  
**Last Updated:** `2025-07-16`

Springs are a powerful tool for creating smooth and responsive animations.  

---

## Restrictions

Type `T` must support the following operations:

1. **Addition (`+`)**  
   → `add(T, T): T`

2. **Subtraction (`-`)**  
   → `sub(T, T): T`

3. **Multiplication (`×`)**  
   → `mul(T, number): T`

4. **Division (`÷`)**  
   → `div(T, number): T`

> *Note: This is achievable using metamethods `__add`, `__sub`, `__mul`, and `__div` for custom types.*

---

## Recommendations

1. **Render loop handling is your responsibility:**
   - You may keep a spring connected at all times, but this may lead to heavier computation.
   - Consider creating a `SpringHandler` module to manage active spring connections.
   - Disconnect unused springs to reduce unnecessary performance costs.

---

## References

1. [Damping – Wikipedia](https://en.wikipedia.org/wiki/Damping)  
2. [Programming in Lua Gems](https://www.lua.org/gems/sample.pdf)  
3. [Luau Native Code Generation – Roblox Docs](https://create.roblox.com/docs/luau/native-code-gen)  
4. [New Type Solver (Beta) – Roblox DevForum](https://devforum.roblox.com/t/new-type-solver-beta/3155804)
