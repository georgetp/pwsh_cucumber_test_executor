class Example {
  [int]$line
  [string[]]$values
  [string[]]$tags

  Example([int]$exampleLine){
    $this.line = $exampleLine
  }
}
