# BatterySafe Watchface

BatterySafe is a **battery-first Garmin watchface** designed to minimize power consumption while still providing meaningful, actionable battery insights.

Unlike many watchfaces, BatterySafe **does not use fitness/sensor metrics** (steps, heart rate, Body Battery, touch, GPS).  
All displayed metrics are derived **exclusively from system battery data + time**, keeping the energy impact extremely low.

---

## 🔋 Core Philosophy

> **Less work per minute = more battery life**

BatterySafe follows three strict principles:

- No sensor access
- Throttled, event-driven updates
- Aggressive caching (data, strings, and graphics)

This makes it suitable for users who prioritize **maximum autonomy**, especially on AMOLED devices with Always-On Display.

---

## ✨ Features

### ⏱ Time & Date
- 12h / 24h format (user selectable)
- Minimal redraw: **time area updates only when the minute changes**
- AOD-safe rendering

---

### 🔋 Battery Percentage
- Native device battery percentage
- Cached and refreshed only when needed (sampling-based)

---

### 📉 Battery Trend (Use / Charge)
Shows how the battery is changing over time using sampled values.

Example:
- `Use: 1.2%` (draining)
- `Chg: 0.8%` (charging)

Notes:
- Sampling interval: **every 15 minutes**
- Rate is computed internally (normalized to 1 hour), but the UI can display a shorter label/value
- Trend string is updated only when the sample window completes

---

### 🔌 Time Since Last Charge
Displayed in the header:

`Since charge: 3d 4h`

- Automatically detected on unplug
- Updated at most once per hour
- Immediate refresh on unplug event

---

### 🔧 Customizable Battery Field (Top Slot)

The secondary top field can be customized:

#### 1) Battery Score
Example: `Score: A`

- Based on current drain rate
- Grades from **A (excellent)** to **E (poor)**

#### 2) Estimated Time Left
Example: `Left: 2d 5h`

- Estimated remaining battery life based on current drain trend
- Calculated from battery percentage and trend

#### 3) Charging Session
Example: `Charging: 45m`

- Shows how long the device has been charging
- Shows the last charging session duration after unplugging

---

## 🌙 Always-On Display (AOD)

BatterySafe includes a highly optimized AOD mode:

- Black background (AMOLED-friendly)
- Only time and date rendered
- Pixel shifting every 10 minutes (burn-in prevention)
- No battery sampling/calculations in AOD
- No dynamic strings in AOD

---

## 🎨 Customization

- Primary color
- Accent color
- 12h / 24h time format
- Custom top battery field (Score / Left / Charging)

Settings are applied:
- Only when changed
- With static renderer invalidation
- Without continuous polling

---

## ⚡ Performance & Battery Optimization

### Key optimizations

- **No sensors** (steps, HR, Body Battery, touch, stress, GPS)
- Battery sampling only every **15 minutes**
- Header refresh limited to **1 hour**
- Charging state checked at most every **5 minutes** (throttled)
- Partial redraws via split dirty flags:
  - `dirtyTime` → redraw time area only
  - `dirtyTopLines` → redraw the battery lines only when needed
- Static graphics cached and redrawn only when needed
- Renderers do **no calculations**: strings are built in the DataManager and only drawn in renderers
- Minimal allocations during `onUpdate()`

---

## 🔍 Power Consumption Notes

BatterySafe is designed to be comparable to (or lower than) very simple digital watchfaces, especially compared to faces that:
- constantly access sensors
- show multiple live metrics
- animate UI elements

> ⚠️ Actual battery impact depends heavily on device model, AOD settings, brightness, notifications, and installed apps.

---

## 🧠 Architecture Overview

- **State**: centralized cached data and strings
- **DataManager**: calculations + throttled updates
- **Renderers**: draw-only components (no formatting)
- **View**: orchestrates refresh, redraw, and AOD handling

---

## 📦 Target Audience

- Users who prioritize battery life
- AMOLED device owners using AOD
- Long outdoor activities / travel
- Minimalist + technical users
- Developers interested in low-power Connect IQ patterns

---

## 🚫 What BatterySafe Does NOT Do

- No steps, heart rate, or fitness metrics
- No animations
- No sensor subscriptions
- No unnecessary redraws

---

## 📜 License

Specify your license here (MIT, Apache 2.0, GPL, etc.)
