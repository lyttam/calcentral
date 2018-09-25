describe CampusSolutions::EmergencyContact do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EmergencyContact.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        contactName: 'Joe'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 28
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:contactName]).to eq 'Joe'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        contactName: 'Joe',
        isSameAddressEmpl: 'N'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['UC_EMER_CNTCT']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['SAME_ADDRESS_EMPL']).to eq 'N'
        expect(subject['CONTACT_NAME']).to eq 'Joe'
      end
    end

    context 'performing a post' do
      let(:params) { {
        contactName: 'Joe',
        isSameAddressEmpl: 'N'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end
end
