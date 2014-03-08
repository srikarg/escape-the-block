width = 800
height = 200
playerColor = '#3498db'
enemyColor = '#e74c3c'
playerJump = 3.5
enemyInitial = 10
enemyIncrease = 1
time = 0
message = ''
messages = [
    'Give up.'
    "You'll never win."
    'Stop trying.'
    'You can never beat your high score!'
    "Try reaching 30 seconds noob."
    "Wow, you're pretty bad at this game."
    'You jump like my grandmother.'
    ''
]
timeInterval = null
messagesInterval = null

suffix = (number) ->
    if number is 1
        return number + ' second'
    return number + ' seconds'

Crafty.init width, height

Crafty.scene 'Loading', () ->
    Crafty.load ['music/background.wav', 'music/jump.wav', 'music/die.wav', 'music/end.wav'], () ->
        Crafty.bind 'KeyDown', (e) ->
            if e.key is 77
                Crafty.audio.toggleMute()
        Crafty.audio.add 'background', 'music/background.wav'
        Crafty.audio.add 'jump', 'music/jump.wav'
        Crafty.audio.add 'die', 'music/die.wav'
        Crafty.audio.add 'end', 'music/end.wav'
        Crafty.audio.play 'background', -1, 1.0
        Crafty.scene 'MainMenu'
    Crafty.e('2D, DOM, Text')
        .css({
            'text-align': 'center'
            'color': 'white'
            'pointer-events': 'none'
        })
        .textFont({
            family: 'Press Start 2P'
            size: '16px'
        })
        .unselectable()
        .text 'Loading...'
        .attr
            w: 600
            h: 300
            x: width/2 - 300
            y: height/2 - 15

Crafty.scene 'MainMenu', () ->
    Crafty.e('2D, DOM, HTML')
        .css({
            'color': 'white'
            'pointer-events': 'none'
            'padding': '16px'
            'text-align': 'center'
        })
        .attr({
            w: width
            h: height
            x: 0
            y: 0
        })
        .replace(
            """
                <style>
                    h1 {
                        text-align: center;
                    }
                </style>
                <h1>Escape the Block!</h1>
                <p>Press p to start playing or i for instructions!</p>
            """
        )
        .requires('Keyboard')
        .bind('KeyDown', () ->
            if this.isDown 73
                Crafty.scene 'Instructions'
            else if this.isDown 80
                Crafty.scene 'Game'
        )

Crafty.scene 'Instructions', () ->
    Crafty.e('2D, DOM, HTML')
        .css({
            'color': 'white'
            'pointer-events': 'none'
            'padding': '16px'
        })
        .attr({
            w: width
            h: height
            x: 0
            y: 0
        })
        .requires 'Keyboard'
        .bind('KeyDown', () ->
            if this.isDown 80
                Crafty.scene 'Game'
        )
        .replace(
            """
                <style>
                    h1 {
                        font-size: 24px;
                    }
                    ul {
                        list-style: none;
                        margin-left: 20px;
                        padding-left: 1em;
                        text-indent: -1em;
                        font-size: 14px;
                    }
                    li {
                        margin: 5px 0;
                    }
                </style>
                <h1>Instructions</h1>
                <ul>
                    <li>&#8594; Don't let the red guy touch you!</li>
                    <li>&#8594; Jump with the &#8593; arrow.</li>
                    <li>&#8594; Try to last as long as possible!</li>
                    <li>&#8594; Press m to mute!</li>
                </ul>
                <p>Press p to start playing!</p>
            """
        )

Crafty.scene 'Game', () ->
    Crafty.background 'black'
    timeInterval = setInterval () ->
        time++
    , 1000
    messagesInterval = setInterval () ->
        random = Math.floor(Math.random() * (messages.length - 0 + 1));
        message = messages[random]
    , 4000
    Crafty.c 'Floor',
        init: () ->
            @requires '2D, Canvas, Collision, Gravity, Color'
            @color 'white'
    Crafty.c 'Object',
        init: () ->
            @requires '2D, Canvas, Gravity, Color'
            @gravity 'Floor'
    Crafty.c 'Player',
        init: () ->
            @requires 'Object, Collision, Multiway'
            @multiway playerJump, { UP_ARROW: -90 }
            @color playerColor
            @bind 'Move', (obj) ->
                if obj._y is height - 40 and @y < height - 40
                    Crafty.audio.play 'jump', 1, 1.0
    Crafty.c 'Enemy',
        speed: enemyInitial
        init: () ->
            @requires 'Object, Collision'
            @color enemyColor
            @bind 'EnterFrame', () ->
                @x -= @speed
                if @x < 0
                    @x = width - 60
                    @speed += enemyIncrease
            @onHit 'Player', () ->
                Crafty.audio.play 'die', 1, 1.0
                Crafty.scene 'EndGame'
    player = Crafty.e('Player').attr
        w: 20
        h: 20
        x: 60
        y: height - 40
    enemy = Crafty.e('Enemy').attr
        w: 20
        h: 20
        x: width + 20
        y: height - 40
    floor = Crafty.e('Floor').attr
        w: width
        h: 20
        x: 0
        y: height - 20
    leftWall = Crafty.e('2D, Canvas, Color').color('white').attr
        w: 20
        h: height
        x: 0
        y: 0
    rightWall = Crafty.e('2D, Canvas, Color').color('white').attr
        w: 20
        h: height
        x: width - 20
        y: 0
    ceiling = Crafty.e('2D, Canvas, Color').color('white').attr
        w: width
        h: 20
        x: 0
        y: 0
    displayMessage = Crafty.e('2D, DOM, Text')
        .css({
            'text-align': 'center'
            'color': 'white'
            'pointer-events': 'none'
        })
        .textFont({
            family: 'Press Start 2P'
            size: '16px'
        })
        .unselectable()
        .bind('EnterFrame', () ->
            @text message
        )
        .attr
            w: 600
            h: 300
            x: width/2 - 300
            y: height/2 - 15
    displayScore = Crafty.e('2D, DOM, Text')
        .css({
            'text-align': 'center'
            'color': 'white'
            'pointer-events': 'none'
        })
        .textFont({
            family: 'Press Start 2P'
            size: '16px'
        })
        .unselectable()
        .bind('EnterFrame', () ->
            @text suffix time
        )
        .attr
            w: 600
            h: 300
            x: width/2 - 300
            y: height/2 - 50

Crafty.scene 'EndGame', () ->
    Crafty.audio.stop 'background'
    Crafty.audio.play 'end', -1, 1.0
    if Crafty.storage('score') is null
        Crafty.storage 'score', "#{ time }"
    else
        if time > Crafty.storage('score')
            Crafty.storage.remove 'score'
            Crafty.storage 'score', "#{ time }"
    Crafty.background '#e74c3c'
    Crafty.e('2D, DOM, Text')
        .css({
            'text-align': 'center'
            'color': 'white'
            'pointer-events': 'none'
        })
        .textFont({
            family: 'Press Start 2P'
            size: '20px'
        })
        .unselectable()
        .text("You survived #{ suffix time }!")
        .attr
            w: 500
            h: 300
            x: width/2 - 250
            y: height/2 - 50
    Crafty.e('2D, DOM, Text')
        .css({
            'text-align': 'center'
            'color': 'white'
            'pointer-events': 'none'
        })
        .textFont({
            family: 'Press Start 2P'
            size: '20px'
        })
        .unselectable()
        .text("Your high score is #{ suffix(parseInt(Crafty.storage('score'))) }!")
        .attr
            w: 600
            h: 300
            x: width/2 - 300
            y: height/2
    Crafty.e('2D, DOM, Text')
        .css({
            'text-align': 'center'
            'color': 'white'
            'pointer-events': 'none'
        })
        .textFont({
            family: 'Press Start 2P'
            size: '16px'
        })
        .unselectable()
        .text('Press space to play again!')
        .requires('Keyboard')
        .bind('KeyDown', () ->
            if this.isDown 'SPACE'
                time = 0
                clearInterval timeInterval
                clearInterval messagesInterval
                message = ''
                Crafty.audio.stop 'end'
                Crafty.audio.play 'background', -1, 1.0
                Crafty.scene 'Game'
        )
        .attr
            w: 500
            h: 300
            x: width/2 - 250
            y: height/2 + 50

Crafty.scene 'Loading'
