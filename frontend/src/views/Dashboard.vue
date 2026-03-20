<template>
  <div class="min-h-screen bg-background px-4 py-6 sm:px-6 sm:py-8">
    <!-- Header -->
    <header
      class="mb-6 flex flex-col gap-3 sm:mb-8 sm:flex-row sm:items-center sm:justify-between"
    >
      <div class="flex items-center gap-3">
        <img
          src="/observer_logo.png"
          class="h-10 w-10 object-contain"
          alt="obSERVER logo"
        />
        <div>
          <h1 class="text-xl font-black tracking-tight text-foreground">
            obSERVER
          </h1>
          <p class="text-xs font-light text-muted-foreground">
            Live server room monitoring dashboard developed by Mariel A.
            Gravidez of MI231
          </p>
        </div>
      </div>
      <div
        class="flex items-center gap-2 text-xs font-light text-muted-foreground"
      >
        <RefreshCw
          :class="[
            'h-3.5 w-3.5 flex-shrink-0',
            isRefreshing ? 'animate-spin text-primary' : '',
          ]"
        />
        <span class="whitespace-nowrap">Auto-refresh every 15s</span>
        <span
          v-if="lastUpdated"
          class="ml-2 whitespace-nowrap text-foreground/50"
        >
          &bull; Last updated {{ lastUpdated }}
        </span>
      </div>
    </header>

    <!-- Error Banner -->
    <div
      v-if="error"
      class="mb-6 flex items-center gap-3 rounded-lg border border-red-900 bg-red-950/60 px-4 py-3 text-sm font-light text-red-300"
    >
      <AlertCircle class="h-4 w-4 flex-shrink-0" />
      <span>{{ error }}</span>
    </div>

    <!-- Tabs -->
    <Tabs default-value="overview">
      <TabsList>
        <TabsTrigger value="overview">Overview</TabsTrigger>
        <TabsTrigger value="history">History</TabsTrigger>
      </TabsList>

      <!-- Tab 1: Status + Sensor Cards + Humidity Chart -->
      <TabsContent value="overview">
        <!-- Status Card + Sensor Data Card -->
        <section class="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2">
          <!-- Status Card -->
          <Card
            class="shadow-sm border-0"
            :style="isWarning ? 'background: #2a0e0e' : 'background: #0e2a0e'"
          >
            <CardContent class="flex h-full items-center gap-4 py-5">
              <div
                class="flex h-14 w-14 flex-shrink-0 items-center justify-center rounded-full bg-white/10 sm:h-16 sm:w-16"
              >
                <AlertTriangle
                  v-if="isWarning"
                  class="h-8 w-8 sm:h-10 sm:w-10"
                  style="color: #ff5555"
                />
                <ShieldCheck
                  v-else
                  class="h-8 w-8 text-primary sm:h-10 sm:w-10"
                />
              </div>
              <div v-if="latest">
                <p
                  class="text-xs font-light tracking-widest text-white/50 uppercase"
                >
                  Status
                </p>
                <span
                  class="text-3xl font-black sm:text-4xl"
                  :style="isWarning ? 'color: #ff5555' : 'color: #08CB00'"
                >
                  {{ isWarning ? "WARNING" : "GOOD" }}
                </span>
                <p class="mt-1 text-xs font-light text-white/60">
                  <span v-if="isWarning">
                    Temperature exceeded {{ TEMP_THRESHOLD }}&deg;C &mdash;
                    alarm active
                  </span>
                  <span v-else>
                    Temperature within safe range (&le;
                    {{ TEMP_THRESHOLD }}&deg;C)
                  </span>
                </p>
              </div>
              <div v-else class="text-3xl font-black text-white/50">--</div>
            </CardContent>
          </Card>

          <!-- Sensor Data Card -->
          <Card class="shadow-sm border-0 bg-card">
            <CardContent class="flex h-full items-center py-5">
              <div v-if="latest" class="flex w-full min-w-0 items-center">
                <!-- Temperature -->
                <div
                  class="flex flex-1 min-w-0 items-center justify-center gap-2 sm:gap-4"
                >
                  <div
                    class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-white/10 sm:h-14 sm:w-14"
                  >
                    <Thermometer class="h-5 w-5 text-primary sm:h-8 sm:w-8" />
                  </div>
                  <div class="min-w-0">
                    <p
                      class="text-[10px] font-light tracking-widest text-white/50 uppercase sm:text-xs"
                    >
                      Temperature
                    </p>
                    <div class="flex items-baseline gap-0.5">
                      <span
                        class="text-2xl font-black text-white sm:text-4xl"
                        >{{ latest.temperature.toFixed(1) }}</span
                      >
                      <span
                        class="text-base font-light text-white/60 sm:text-xl"
                        >&deg;C</span
                      >
                    </div>
                  </div>
                </div>
                <!-- Divider -->
                <div
                  class="mx-2 h-12 w-px flex-shrink-0 bg-white/10 sm:mx-4 sm:h-16"
                ></div>
                <!-- Humidity -->
                <div
                  class="flex flex-1 min-w-0 items-center justify-center gap-2 sm:gap-4"
                >
                  <div
                    class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-white/10 sm:h-14 sm:w-14"
                  >
                    <Droplets class="h-5 w-5 text-primary sm:h-8 sm:w-8" />
                  </div>
                  <div class="min-w-0">
                    <p
                      class="text-[10px] font-light tracking-widest text-white/50 uppercase sm:text-xs"
                    >
                      Humidity
                    </p>
                    <div class="flex items-baseline gap-0.5">
                      <span
                        class="text-2xl font-black text-white sm:text-4xl"
                        >{{ latest.humidity.toFixed(1) }}</span
                      >
                      <span
                        class="text-base font-light text-white/60 sm:text-xl"
                        >%</span
                      >
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="text-3xl font-black text-white/50">--</div>
            </CardContent>
          </Card>
        </section>

        <!-- Humidity Line Chart -->
        <section>
          <Card>
            <CardHeader>
              <div class="flex items-center gap-2">
                <Activity class="h-4 w-4 text-primary" />
                <CardTitle class="text-sm font-black"
                  >Temperature & Humidity Over Time</CardTitle
                >
              </div>
              <p class="text-xs font-light text-muted-foreground">
                Last 10 readings (%)
              </p>
            </CardHeader>
            <CardContent>
              <div v-if="chartReadings.length > 0" class="h-48 sm:h-52">
                <Line :data="humidityChartData" :options="chartOptions" />
              </div>
              <div
                v-else
                class="flex h-48 items-center justify-center text-sm font-light text-muted-foreground sm:h-52"
              >
                Waiting for data...
              </div>
            </CardContent>
          </Card>
        </section>
      </TabsContent>

      <!-- Tab 2: Data Table -->
      <TabsContent value="history">
        <section>
          <Card>
            <CardHeader>
              <div class="flex items-center gap-2">
                <TableIcon class="h-4 w-4 text-muted-foreground" />
                <CardTitle class="text-sm font-black"
                  >Recent Readings</CardTitle
                >
              </div>
              <p class="text-xs font-light text-muted-foreground">
                Latest 20 entries from the database
              </p>
            </CardHeader>
            <CardContent class="p-0">
              <Table>
                <TableHeader>
                  <TableRow class="bg-muted/40 hover:bg-muted/40">
                    <TableHead class="w-12 pl-6 font-black">#</TableHead>
                    <TableHead class="font-black">
                      <div class="flex items-center gap-1.5">
                        <Thermometer class="h-3.5 w-3.5 text-primary" />
                        Temperature (&deg;C)
                      </div>
                    </TableHead>
                    <TableHead class="font-black">
                      <div class="flex items-center gap-1.5">
                        <Droplets class="h-3.5 w-3.5 text-primary" />
                        Humidity (%)
                      </div>
                    </TableHead>
                    <TableHead class="font-black">
                      <div class="flex items-center gap-1.5">
                        <Clock class="h-3.5 w-3.5 text-muted-foreground" />
                        Timestamp
                      </div>
                    </TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow v-if="tableReadings.length === 0">
                    <TableCell
                      colspan="4"
                      class="py-10 text-center text-sm font-light text-muted-foreground pl-6"
                    >
                      No readings yet. Waiting for data from the sensor...
                    </TableCell>
                  </TableRow>
                  <TableRow
                    v-for="(reading, index) in tableReadings"
                    :key="reading.id"
                    :class="index % 2 === 0 ? 'bg-card' : 'bg-muted/20'"
                  >
                    <TableCell
                      class="pl-6 font-mono text-xs font-light text-muted-foreground"
                      >{{ reading.id }}</TableCell
                    >
                    <TableCell>
                      <span class="font-light text-white">{{
                        reading.temperature.toFixed(1)
                      }}</span>
                      <span class="ml-1 text-xs font-light text-white/60"
                        >&deg;C</span
                      >
                    </TableCell>
                    <TableCell>
                      <span class="font-light text-white">{{
                        reading.humidity.toFixed(1)
                      }}</span>
                      <span class="ml-1 text-xs font-light text-white/60"
                        >%</span
                      >
                    </TableCell>
                    <TableCell class="text-sm font-light text-muted-foreground">
                      {{ formatTimestamp(reading.createdAt) }}
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </section>
      </TabsContent>
    </Tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue"
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
  type ChartOptions,
} from "chart.js"
import { Line } from "vue-chartjs"
import {
  Thermometer,
  Droplets,
  RefreshCw,
  AlertCircle,
  AlertTriangle,
  ShieldCheck,
  Clock,
  Table as TableIcon,
  Activity,
} from "lucide-vue-next"

import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table"
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"
import { fetchReadings } from "@/services/api"
import type { Reading } from "@/types/reading"

// Register Chart.js modules
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

// Temperature threshold for WARNING state (degrees Celsius)
const TEMP_THRESHOLD = 31

const readings = ref<Reading[]>([])
const error = ref<string | null>(null)
const isRefreshing = ref(false)
const lastUpdated = ref<string | null>(null)

let refreshInterval: ReturnType<typeof setInterval> | null = null

// Most recent reading for the status and sensor cards
const latest = computed<Reading | null>(() =>
  readings.value.length > 0 ? readings.value[0] : null
)

// WARNING when the latest temperature exceeds the threshold
const isWarning = computed<boolean>(
  () => latest.value !== null && latest.value.temperature > TEMP_THRESHOLD
)

// Last 10 readings reversed to chronological order for the chart
const chartReadings = computed<Reading[]>(() =>
  [...readings.value].slice(0, 10).reverse()
)

// Last 20 readings ordered by most recent for the history table
const tableReadings = computed<Reading[]>(() =>
  [...readings.value].slice(0, 20).sort((a, b) => b.id - a.id)
)

// Labels derived from timestamps for the chart x-axis
const chartLabels = computed<string[]>(() =>
  chartReadings.value.map((r) => formatChartLabel(r.createdAt))
)

const humidityChartData = computed(() => ({
  labels: chartLabels.value,
  datasets: [
    {
      label: "Temperature (\u00b0C)",
      data: chartReadings.value.map((r) => r.temperature),
      borderColor: "#08CB00",
      backgroundColor: "rgba(8, 203, 0, 0.15)",
      borderWidth: 2,
      pointRadius: 3,
      pointHoverRadius: 5,
      tension: 0.3,
      fill: true,
    },
    {
      label: "Humidity (%)",
      data: chartReadings.value.map((r) => r.humidity),
      borderColor: "#06923E",
      backgroundColor: "rgba(6, 146, 62, 0.15)",
      borderWidth: 2,
      pointRadius: 3,
      pointHoverRadius: 5,
      tension: 0.3,
      fill: true,
    },
  ],
}))

// Custom plugin: draw a vertical crosshair line on hover
const crosshairPlugin = {
  id: "crosshair",
  afterDatasetsDraw(chart: any) {
    const active = chart.tooltip?._active
    if (!active || active.length === 0) return
    const x = active[0]?.element?.x
    if (x == null) return
    const ctx: CanvasRenderingContext2D = chart.ctx
    const topY = chart.scales.y.top
    const bottomY = chart.scales.y.bottom
    ctx.save()
    ctx.beginPath()
    ctx.moveTo(x, topY)
    ctx.lineTo(x, bottomY)
    ctx.lineWidth = 1
    ctx.strokeStyle = "rgba(255, 255, 255, 0.25)"
    ctx.setLineDash([4, 4])
    ctx.stroke()
    ctx.restore()
  },
}
ChartJS.register(crosshairPlugin)

// Shared chart options
const chartOptions: ChartOptions<"line"> = {
  responsive: true,
  maintainAspectRatio: false,
  interaction: {
    mode: "index",
    intersect: false,
  },
  plugins: {
    legend: {
      display: true,
      position: "top",
      align: "end",
      labels: {
        color: "#94a3b8",
        font: { size: 11 },
        boxWidth: 12,
        boxHeight: 2,
        padding: 16,
        usePointStyle: true,
        pointStyle: "line",
      },
    },
    tooltip: {
      mode: "index",
      intersect: false,
      backgroundColor: "#0e2a0e",
      titleColor: "#08CB00",
      bodyColor: "#ffffff",
      padding: 10,
      cornerRadius: 8,
      displayColors: false,
    },
  },
  scales: {
    x: {
      grid: { display: false },
      ticks: {
        color: "#94a3b8",
        font: { size: 10 },
        maxTicksLimit: 8,
        maxRotation: 0,
      },
    },
    y: {
      grid: { color: "rgba(255,255,255,0.05)" },
      ticks: { color: "#94a3b8", font: { size: 10 } },
      beginAtZero: false,
    },
  },
}

// Format a timestamp for chart labels (HH:MM:SS)
function formatChartLabel(isoString: string): string {
  const d = new Date(isoString)
  return d.toLocaleTimeString("en-PH", {
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  })
}

// Format a timestamp for the data table (full readable date + time)
function formatTimestamp(isoString: string): string {
  const d = new Date(isoString)
  return d.toLocaleString("en-PH", {
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  })
}

async function loadReadings(): Promise<void> {
  isRefreshing.value = true
  try {
    readings.value = await fetchReadings(50)
    error.value = null
    lastUpdated.value = new Date().toLocaleTimeString("en-PH", {
      hour12: false,
    })
  } catch (err) {
    error.value =
      "Could not reach the backend API. Make sure the backend server is running on http://localhost:3000."
    console.error(err)
  } finally {
    isRefreshing.value = false
  }
}

onMounted(() => {
  loadReadings()
  // Poll every 15 seconds to match the Arduino sending interval
  refreshInterval = setInterval(loadReadings, 15000)
})

onUnmounted(() => {
  if (refreshInterval !== null) {
    clearInterval(refreshInterval)
  }
})
</script>
