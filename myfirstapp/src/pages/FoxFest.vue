<template>
  <q-page class="q-gutter-md q-ma-md">
    <div class="text-h6">This is the customer page</div>
    <q-input flat label="Name" v-model="customername" />
    <q-checkbox label="Active" v-model="active" />
    <q-select v-model="option" :options="options" />
    <q-btn flat icon="save" @click="saveit" label="Save" />
  </q-page>
</template>

<script>
export default {
  name: 'Customer',
  data () {
    return {
      customername: null,
      active: false,
      options: ['Visual FoxPro', 'Quasar', 'React', 'West-Wind'],
      option: null
    }
  },
  mounted () {

  },
  methods: {
    saveit () {
      this.$q.notify({ message: 'Saved' })
    }
  }
}
</script>
