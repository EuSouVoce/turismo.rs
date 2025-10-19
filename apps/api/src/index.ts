import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.json({ message: 'API do turismo.rs está no ar!' })
})

export default {
  port: 4000,
  fetch: app.fetch,
}
