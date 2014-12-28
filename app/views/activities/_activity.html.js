<script type="text/template" id="activity">
  <tr data-id="{0}" data-email="{3}">
    <td class="col-md-8"><a href="/members/{1}">{2}</a></td>
    <td class="col-md-2">
      <input class="price" type="text" value="{4}">
    </td>
    <td class="col-md-2">
      <div class="btn-group">
        <button class="btn btn-warning paid">
          <i class="fa fa-fw fa-times"></i>
        </button>
        <button class="btn btn-default destroy">
          <i class="fa fa-fw fa-trash-o"></i>
        </button>
      </div>
    </td>
  </tr>
</script>