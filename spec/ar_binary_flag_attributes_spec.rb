require 'spec_helper'

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
SampleMigration.run

describe ActiveRecord::Base do
  it "should use binary attributes on SampleModel (1)" do
    s = SampleModel.create
    s.a = true
    s.b = true
    s.c = true
    s.save!

    s.flags.should == (1+2+4)
  end

  it "should use binary attributes on SampleModel (2)" do
    s = SampleModel.create
    s.a = true
    s.b = false
    s.c = true
    s.save!

    s.flags.should == (1+4)
  end

  it "should use binary attributes on SampleModel (3)" do
    s = SampleModel.create
    s.a = false
    s.b = false
    s.c = true
    s.save!

    s.flags.should == (4)
  end

  it "should use binary attributes on SampleModel - reversed" do
    s = SampleModel.create
    s.flags = 7
    s.save!

    s.a.should
    s.b.should
    s.c.should
  end

  it "should use binary attributes on SampleModel - WTF1" do
    s = SampleModel.create
    s.flags = -1
    s.save!

    s.a.should_not
    s.b.should_not
    s.c.should_not
  end

  it "should use binary attributes on SampleModel - WTF2" do
    s = SampleModel.create
    s.flags = 256
    s.save!

    s.a.should_not
    s.b.should_not
    s.c.should_not
  end

  it "should use binary attributes on SampleModel using default values from checkbox ('0','1')" do
    s = SampleModel.create
    s.a = '0'
    s.b = '0'
    s.c = '1'
    s.save!

    s.flags.should == (4)
  end

  it "should use binary attributes on SampleModel using default values from checkbox ('0','1')" do
    s = SampleModel.create
    s.a = 0
    s.b = 0
    s.c = 1
    s.save!

    s.flags.should == (4)
  end

end
