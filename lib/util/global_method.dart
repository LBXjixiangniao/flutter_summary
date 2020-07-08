Function blocCondition<T>() {
  return (pre, current) {
    return (current is T);
  };
}
