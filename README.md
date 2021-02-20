# 🌵 ➡️ 🌸 PlantWatcher

This project is for my own personal use and I take no responibility for any incident of killed plants or flooded apartments.

## 💡 Background

When I last year got my first apartment with a balcony, I realized that keeping the plats from dying wouldn't be as easy as it seems. After killing off several of them during my first months in Berlin (where the weather, in fact, is pretty warm and sunny during the summer months), I concluded that I would need a watering system.

My little pet project went, as they often tend to do, totally out of hand. After more than a few weekends in lockdown, and a winter break, I ended up with the following solution for my balcony.

<img src="./priv/sensors/overview.jpg" alt="L298 DC Motor Driver Board" width="30%" style="display: inline-block;"/>
    
*The setup of the testing done in January, a "nicer" photo will be uploaded as soon as the snow is gone...*

## 🎨 Design

I built the system with as little logic included as possible. One floating meter was attached to a flower pot with a built-in irrigation system to keep track of that the flowers had enough water. Next to the flower pot, I placed a bucket filled with water. If the floating meter indicated that more water is needed, the pump started pumping water from the bucket over to the flower pot.

An additional floating meter was also attached to the bottom of the bucket. If the bucket would be empty - the pump wouldn't start at all (to prevent the pump from breaking).

This solution still requires manual work (I'd need to refill the bucket needs now and then). However, if you're brave enough and trust that your code is bug-free, a liquid valve or similar could replace the pump.

<img src="./priv/sensors/design.png" alt="Design" width="100%" style="display: inline-block;"/>

## 🛰 Hardware

- 1 x [RaspberryPi Zero](https://medium.com/r/?url=https%3A%2F%2Fwww.electrokit.com%2Fen%2Fproduct%2Fraspberry-pi-zero-w-board-2%2F)
- 1 x [Water pump mini 5V](https://medium.com/r/?url=https%3A%2F%2Fwww.electrokit.com%2Fen%2Fproduct%2Fvattenpump-mini-5v%2F)
- 2 x [Float switch magnetic NO](https://medium.com/r/?url=https%3A%2F%2Fwww.electrokit.com%2Fen%2Fproduct%2Ffloat-switch-magnetic-no%2F)
- 1 x [Relay module 5V][https://medium.com/r/?url=https%3a%2f%2fwww.electrokit.com%2fen%2fproduct%2frelay-module-5v%2f]
- [Speaker cables](https://medium.com/r/?url=https%3A%2F%2Fwww.electrokit.com%2Fen%2Fproduct%2Fkabel-2x4-0-rod-svart-m%2F) (I used about 4-5 meters for my setup, and it was more than enough)
- [Flower pot with irrigation system](https://medium.com/r/?url=https%3A%2F%2Fwww.obi.de%2Fpflanzentoepfe-aussen%2Febertsankey-blumenkasten-mediterran-mit-bewaesserungssystem-100-cm-anthrazit%2Fp%2F4444444)
- 1 x [bucket](https://medium.com/r/?url=https%3A%2F%2Fwww.ikea.com%2Fde%2Fde%2Fp%2Fhallbar-behaelter-mit-deckel-hellgrau-80398058%2F)

### Hardware assembly

<img src="./priv/sensors/circuit-diagram.png" alt="Design" width="100%" style="display: inline-block;"/>

_Created with [https://www.circuit-diagram.org/editor/](https://www.circuit-diagram.org/editor/)_

Please note that I've never studied electrical engineering and that the following circuit diagram could be way off. Use common sense while assembling.

## 👩‍💻 Software

Feel free to use and abuse the code however you like, however, please note that the code was written for my own personal use and I take no responsibility for any incident of killed plants or flooded apartments. :)

### Prerequisites

The pigpio C library (http://abyz.me.uk/rpi/pigpio/)

### Getting started

**Install Erlang**

```
sudo apt-get install erlang
```

**Install the pigpio library**

```
sudo apt-get install pigpio
```

**Install pigpio**

```
sudo apt-get install pigpio python-pigpio python3-pigpio
```

**Start the pigpio daemon**

```
sudo pigpiod
```

**Start the web server**

```
make run
```

An API skeletton is running on port 3000.

### References

Erlang socket bindings to pigpio: https://github.com/skvamme/pigpio
