shared_examples_for 'custom_data_storage' do

  RESERVED_FIELDS = %w( createdAt modifiedAt meta spMeta spmeta ionMeta ionmeta )

  it 'read reserved data' do
    expect(custom_data_storage.custom_data["href"]).not_to eq(nil)
    expect(custom_data_storage.custom_data["createdAt"]).not_to eq(nil)
    expect(custom_data_storage.custom_data["modifiedAt"]).not_to eq(nil)
  end

  RESERVED_FIELDS.each do |reserved_field|
    it "set reserved data #{reserved_field} should raise error" do
      custom_data_storage.custom_data[reserved_field] = 12
      expect{ custom_data_storage.custom_data.save }.to raise_error
    end
  end

  it 'should save properly when custom data is nested on creation' do
    expect(custom_data_storage_w_nested_custom_data.custom_data["rank"]).to eq("Captain")
    expect(custom_data_storage_w_nested_custom_data.custom_data["favorite_drink"]).to eq("Earl Grey Tea")
    expect(custom_data_storage_w_nested_custom_data.custom_data["favoriteDrink"]).to eq("Camelized Tea")
  end

  it 'set custom data' do
    custom_data_storage.custom_data[:rank] = "Captain"
    expect(custom_data_storage.custom_data[:rank]).to eq("Captain")
    custom_data_storage.custom_data.save
    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq("Captain")
  end

  it 'set nested custom data' do
    custom_data_storage.custom_data[:special_rank] = "Captain"
    custom_data_storage.custom_data[:permissions] = {"crew_quarters" => "93-601"}
    expect(custom_data_storage.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
    custom_data_storage.custom_data.save
    expect(reloaded_custom_data_storage.custom_data[:special_rank]).to eq("Captain")
    expect(reloaded_custom_data_storage.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
  end

  it 'not raise errors when saving a empty properties array' do
    custom_data_storage.custom_data.save
  end

  it 'trigger custom data saving on custom_data_storage.save' do
    custom_data_storage.custom_data[:rank] = "Captain"
    custom_data_storage.save
    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq("Captain")
  end

  it 'trigger custom data saving on custom_data_storage.save with complex custom data' do
    custom_data_storage.custom_data[:permissions] = {"crew_quarters" => "93-601"}
    custom_data_storage.save
    expect(reloaded_custom_data_storage.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})
  end

  it 'update custom data through custom_data_storage.save, cache should be cleared' do
    custom_data_storage.custom_data[:permissions] = {"crew_quarters" => "93-601"}
    custom_data_storage.custom_data.save

    expect(reloaded_custom_data_storage.custom_data[:permissions]).to eq({"crew_quarters" => "93-601"})

    reloaded_custom_data_storage.custom_data[:permissions] = {"crew_quarters" => "601-93"}

    reloaded_custom_data_storage.save
    expect(reloaded_custom_data_storage_2.custom_data[:permissions]).to eq({"crew_quarters" => "601-93"})
  end

  it 'first level keys can be saved as symbols or strings, they will default to the same (saved as strings)' do
    custom_data_storage.custom_data[:permissions] = "Drive the boat"
    expect(custom_data_storage.custom_data[:permissions]).to eq("Drive the boat");
    expect(custom_data_storage.custom_data["permissions"]).to eq(custom_data_storage.custom_data[:permissions])

    custom_data_storage.custom_data.save
    expect(custom_data_storage.custom_data[:permissions]).to eq("Drive the boat");
    expect(custom_data_storage.custom_data["permissions"]).to eq(custom_data_storage.custom_data[:permissions])
  end

  it "one shouldn't save deeply nested keys as symbols, as on return from the server they will be strings" do
    custom_data_storage.custom_data[:permissions] = { driving_privelage: "Boat", can_swim: true }
    expect(custom_data_storage.custom_data[:permissions]).to eq({ driving_privelage: "Boat", can_swim: true })
    custom_data_storage.custom_data.save
    expect(custom_data_storage.custom_data[:permissions]).to eq({ "driving_privelage" => "Boat", "can_swim" => true })
    expect(custom_data_storage.custom_data[:permissions]).not_to eq({ driving_privelage: "Boat", can_swim: true })
  end

  it 'delete all custom data and rebind without reloading' do
    custom_data_storage.custom_data["a_map"] = {the_key: "this is the value"}
    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["a_map"]).to eq({"the_key" => "this is the value"})

    custom_data_storage.custom_data.delete("a_map")
    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["a_map"]).to be_nil

    custom_data_storage.custom_data["rank"] = "Captain"
    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["rank"]).to eq("Captain")

    custom_data_storage.custom_data.delete

    expect(custom_data_storage.custom_data["a_map"]).to be_nil
    expect(custom_data_storage.custom_data["rank"]).to be_nil

    custom_data_storage.custom_data['new_stuff'] = "the value"
    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["new_stuff"]).to eq("the value")
    custom_data_storage.custom_data.delete("new_stuff")

    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["new_stuff"]).to be_nil
  end

  it 'delete all custom data and rebind without reloading through custom_data_storage#save' do
    custom_data_storage.custom_data["a_map"] = {"the_key" => "this is the value"}
    custom_data_storage.save

    expect(custom_data_storage.custom_data["a_map"]).to eq({"the_key" => "this is the value"})

    custom_data_storage.custom_data.delete("a_map")
    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["a_map"]).to be_nil

    custom_data_storage.custom_data["rank"] = "Captain"
    custom_data_storage.save

    expect(custom_data_storage.custom_data["rank"]).to eq("Captain")

    custom_data_storage.custom_data.delete

    expect(custom_data_storage.custom_data["a_map"]).to be_nil
    expect(custom_data_storage.custom_data["rank"]).to be_nil

    custom_data_storage.custom_data['new_stuff'] = "the value"
    custom_data_storage.save

    expect(custom_data_storage.custom_data["new_stuff"]).to eq("the value")

    custom_data_storage.custom_data.delete("new_stuff")
    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["new_stuff"]).to be_nil
  end

  it 'delete all custom data' do
    custom_data_storage.custom_data[:rank] = "Captain"
    custom_data_storage.custom_data.save
    expect(custom_data_storage.custom_data[:rank]).to eq("Captain")
    custom_data_storage.custom_data.delete
    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq(nil)
  end

  it 'delete all custom data and re-add new custom data' do
    custom_data_storage.custom_data[:rank] = "Captain"

    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data[:rank]).to eq("Captain")

    custom_data_storage.custom_data.delete

    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq(nil)

    reloaded_custom_data_storage.custom_data[:rank] = "Pilot"

    reloaded_custom_data_storage.custom_data.save

    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq("Pilot")

    expect(reloaded_custom_data_storage_2.custom_data[:rank]).to eq("Pilot")
  end

  it "shouldn't be the same if the key is lowercased or camelcased" do

    favorite_drink = "Earl Grey Tea";
    custom_data_storage.custom_data["favorite_drink"] = favorite_drink

    expect(custom_data_storage.custom_data["favorite_drink"]).to eq(favorite_drink)
    expect(custom_data_storage.custom_data["favoriteDrink"]).to be_nil

    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["favorite_drink"]).to eq(favorite_drink)
    expect(custom_data_storage.custom_data["favoriteDrink"]).to be_nil

    custom_data_storage.custom_data.delete("favorite_drink")

    expect(custom_data_storage.custom_data["favorite_drink"]).to be_nil
    expect(custom_data_storage.custom_data["favoriteDrink"]).to be_nil

    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data["favorite_drink"]).to be_nil
    expect(custom_data_storage.custom_data["favoriteDrink"]).to be_nil
  end

  it 'delete a specific custom data field' do
    custom_data_storage.custom_data[:rank] = "Captain"
    custom_data_storage.custom_data["favorite_drink"] = "Earl Grey Tea"
    custom_data_storage.custom_data.save
    
    custom_data_storage.custom_data.delete(:rank)
    custom_data_storage.custom_data.save

    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq(nil)

    expect(reloaded_custom_data_storage.custom_data["favorite_drink"]).to eq("Earl Grey Tea")
  end


  it '#has_key?' do
    expect(custom_data_storage.custom_data.has_key? "createdAt").to be_true
    expect(custom_data_storage.custom_data.has_key? "created_at").not_to be_true
  end

  it '#include?' do
    expect(custom_data_storage.custom_data.include? "createdAt").to be_true
    expect(custom_data_storage.custom_data.include? "created_at").not_to be_true
  end

  it '#has_value?' do
    custom_data_storage.custom_data[:rank] = "Captain"
    custom_data_storage.custom_data.save
    expect(reloaded_custom_data_storage.custom_data.has_value? "Captain").to be_true
  end

  it '#store' do
    custom_data_storage.custom_data.store(:rank, "Captain")
    custom_data_storage.custom_data.save
    expect(reloaded_custom_data_storage.custom_data[:rank]).to eq("Captain")
  end

  it '#store with a snakecased key' do
    custom_data_storage.custom_data.store(:super_rank, "Captain")

    expect(custom_data_storage.custom_data[:super_rank]).to eq("Captain")
    expect(custom_data_storage.custom_data["super_rank"]).to eq("Captain")

    expect(custom_data_storage.custom_data[:superRank]).to be_nil
    expect(custom_data_storage.custom_data["superRank"]).to be_nil

    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data[:super_rank]).to eq("Captain")
    expect(custom_data_storage.custom_data["super_rank"]).to eq("Captain")

    expect(custom_data_storage.custom_data[:superRank]).to be_nil
    expect(custom_data_storage.custom_data["superRank"]).to be_nil
  end

    it '#store with a lower camelCase key' do
    custom_data_storage.custom_data.store(:superRank, "Captain")

    expect(custom_data_storage.custom_data[:superRank]).to eq("Captain")
    expect(custom_data_storage.custom_data["superRank"]).to eq("Captain")

    expect(custom_data_storage.custom_data[:super_rank]).to be_nil
    expect(custom_data_storage.custom_data["super_rank"]).to be_nil

    custom_data_storage.custom_data.save

    expect(custom_data_storage.custom_data[:superRank]).to eq("Captain")
    expect(custom_data_storage.custom_data["superRank"]).to eq("Captain")

    expect(custom_data_storage.custom_data[:super_rank]).to be_nil
    expect(custom_data_storage.custom_data["super_rank"]).to be_nil
  end

  it '#keys' do
    expect(custom_data_storage.custom_data.keys).to be_kind_of(Array)
    expect(custom_data_storage.custom_data.keys).to have_at_least(3).items
    expect(custom_data_storage.custom_data.keys).to eq(custom_data_storage.custom_data.properties.keys)
  end

  it '#values' do
    custom_data_storage.custom_data[:permissions] = {"crew_quarters" => "93-601"}
    custom_data_storage.custom_data.save
    expect(reloaded_custom_data_storage.custom_data.values).to include({"crew_quarters" => "93-601"})
    expect(reloaded_custom_data_storage.custom_data.values).to eq(reloaded_custom_data_storage.custom_data.properties.values)
  end

end