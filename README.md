# BatterySafe Watchface

BatterySafe is a **battery-first Garmin watchface** designed to minimize power consumption while still providing meaningful and actionable battery insights.

Unlike traditional watchfaces, BatterySafe **does not use sensors** (steps, heart rate, body battery, touch, GPS).  
All displayed metrics are derived **exclusively from system battery data and time**, ensuring extremely low energy impact.

---

## 🔋 Core Philosophy

> **Less sensors = less wakeups = more battery life**

BatterySafe follows three strict principles:

- No sensor access
- Event-driven updates only
- Aggressive caching (data, strings, and graphics)

This makes it suitable for users who prioritize **maximum autonomy**, especially on AMOLED devices with Always-On Display.

---

## ✨ Features

### ⏱ Time & Date
- 12h / 24h format (user selectable)
- Minimal redraw (only when minute changes)
- AOD-safe rendering

---

### 🔋 Battery Percentage
- Native device battery percentage
- Cached and refreshed only when needed

---

### 📈 Battery Drain Trend
Shows how fast the battery is currently draining.

Drain: 1.2%/h

- Calculated from sampled battery percentage
- Sampling interval: **every 15 minutes**
- No smoothing, no background polling
- Cached string, updated only when trend changes

---

### 🔌 Time Since Last Charge
Displayed in the header:

Since charge: 3d 4h


- Automatically detected when unplugging the charger
- Updated at most once per hour
- Immediate refresh on unplug event

---

### 🔧 Customizable Battery Field (Top Slot)

User can choose what to display in the secondary top field:

#### 1. Battery Efficiency Score

Efficiency: A


- Based on current drain rate
- Grades from **A (excellent)** to **E (poor)**

---

#### 2. Estimated Time Remaining

Remaining: 2d 5h

- Estimated remaining battery life at current drain rate
- Calculated from battery percentage and drain trend
- Automatically adapts to hours-only view when < 24h

---

#### 3. Charging Session Duration

Charging: 45m


- Shows how long the device has been charging
- Displays last charging session when unplugged

---

## 🌙 Always-On Display (AOD)

BatterySafe includes a highly optimized AOD mode:

- Black background (AMOLED-friendly)
- Only time and date rendered
- Pixel shifting every 10 minutes (burn-in prevention)
- No battery calculations in AOD
- No dynamic strings

---

## 🎨 Customization

- Primary color selection
- Accent color selection
- 12h / 24h time format
- Customizable battery field (Efficiency / Remaining / Charging)

All settings are applied:
- Only when changed
- With static renderer invalidation
- Without continuous polling

---

## ⚡ Performance & Battery Optimization

### Key Optimizations

- **No sensors** (steps, HR, Body Battery, touch, stress, GPS)
- Battery sampling only every **15 minutes**
- Header refresh limited to **1 hour**
- Partial redraws using dirty flags
- Static graphics cached and redrawn only when needed
- All strings are cached in state (no formatting during draw)
- Minimal allocations during `onUpdate()`

---

## 🔍 Power Consumption Comparison

Relative consumption (qualitative):

| Watchface Type | Relative Consumption |
|----------------|----------------------|
| BatterySafe | **1.0× (baseline)** |
| Simple stock digital | ~1.2–1.4× |
| Stock with steps / Body Battery | ~1.5–1.8× |
| Typical store watchface | ~2.0× |
| Animated watchface | 3×+ |

BatterySafe typically consumes **less power than Garmin stock watchfaces that include fitness metrics**.

---

## 🧠 Architecture Overview

- **State**: Centralized cached data and strings
- **DataManager**: Event-driven calculations and throttled updates
- **Renderers**: Passive, draw-only components
- **View**: Orchestrates refresh, redraw, and AOD handling

No renderer performs calculations or string formatting.

---

## 📦 Target Audience

- Users who prioritize battery life
- AMOLED device owners using AOD
- Long outdoor activities / travel
- Minimalist and technical users
- Developers interested in low-power Connect IQ patterns

---

## 🚫 What BatterySafe Does NOT Do

- No steps, heart rate, or fitness metrics
- No animations
- No background polling
- No sensor subscriptions
- No unnecessary redraws

---

## 📜 License

Specify your license here (MIT, Apache 2.0, GPL, etc.)

---

## 🙌 Credits

Designed and developed with a focus on **energy efficiency, clarity, and robustness**.

