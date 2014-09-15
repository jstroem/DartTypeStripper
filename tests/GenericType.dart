class Foo<T> {

  T foo;
  List<T> bar;

  Foo(T this.foo);

  T add (T arg){ T v = arg; return v; }
  T apply (T arg, T f(T lol)){ T v = arg; return f(v); }
  

  test() {
     for (T i in foo){

     }
  }
}