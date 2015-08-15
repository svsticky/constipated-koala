<script type="text/template" id="group_member">
  <tr data-id="{0}">
    <td><a href="/members/{1}">{2}</a></td>
    <td>
      <div class="ui-select">
        <select class="position" id="position" name="position">
          <option value=""></option>
          <option value="chairman">Voorzitter</option>
          <option value="treasurer">Penningmeester</option>
        </select>
      </div>
    </td>
    <td class="buttons">
      <button class="btn btn-default destroy pull-right">
        <i class="fa fa-fw fa-trash-o"></i>
      </button>
    </td>
  </tr>
</script>
