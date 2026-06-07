function fish_greeting
    set seed (random 1 101)
    set greet "Hello, World!"
    
    if test $seed -lt 10
        set greet "Hello, World!"
    else if test $seed -lt 20
        set greet "Good Luck!"
    else if test $seed -lt 30
        set greet "May the Force!"
    else if test $seed -lt 40
        set greet "Stay Hungry, Stay Foolish!"
    else if test $seed -lt 50
        set greet "Awesome Fish!"
    else if test $seed -lt 60
        set greet "Deja vu!"
    else if test $seed -lt 70
        set greet "Never dig down!"
    else if test $seed -lt 80
        set greet "Omnipotent!"
    else if test $seed -lt 90
        set greet "Just Do It!!!!"
    else if test $seed -lt 100
        set greet "Alice In the Freezer."
    else
        set greet "Super Lucky Day!?"

    end

    figlet $greet
end
