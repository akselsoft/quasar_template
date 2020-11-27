<template>
  <q-page class="flex flex-center">
    <img alt="Virtual FoxFest logo" src="https://virtualfoxfest.com/images/ZoomFoxSmall.png" />
  </q-page>
</template>

<script>
export default {
  name: 'PageIndex',
  mounted () {
    this.$q.notify({ message: 'hello', color: 'red', position: 'top' })
  }
}
</script>
